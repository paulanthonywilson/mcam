// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import { Socket } from "phoenix"
import NProgress from "nprogress"
import { LiveSocket } from "phoenix_live_view"


let Hooks = {};

let socket = null;
const connectToWebsocket = img => {
    console.log("connecting ...")
    let url = img.dataset.binaryWsUrl;

    socket = new WebSocket(url);
    socket.hasErrored = false;
    socket.onopen = () => {
        console.log("open");
    };

    socket.onclose = () => {
        maybeReopen(img, socket.hasErrored ? 2000 : 0);
        console.log("close", socket);
    };

    socket.onerror = errorEvent => {
        socket.hasErrored = true;
        console.log("error", errorEvent);
    };

    socket.onmessage = messageEvent => {
        let oldImageUrl = img.src;
        let imageUrl = URL.createObjectURL(messageEvent.data);
        img.src = imageUrl;

        if (oldImageUrl != "") {
            URL.revokeObjectURL(oldImageUrl);
        }
    };
};

let isSocketClosed = () => {
    return socket == null || socket.readyState == 3;
};

let maybeReopen = (img, after) => {
    setTimeout(() => {
        if (isSocketClosed()) connectToWebsocket(img);
    }, after);
};


const maybeReconnectWebSocket = (el, socket) => {
    if (isSocketClosed()) {
        connectToWebsocket(el);
    }
};




Hooks.ImageHook = {
    mounted() {
        connectToWebsocket(this.el);
        setInterval(() => { maybeReconnectWebSocket(this.el, socket) }, 30000);
    }
};


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } });

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start());
window.addEventListener("phx:page-loading-stop", info => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

