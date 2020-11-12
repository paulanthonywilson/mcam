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
    let url = img.dataset.binaryWsUrl;

    socket = new WebSocket(url);
    socket.onopen = () => {
        console.log("open");
    };

    socket.onclose = () => {
        console.log("close", socket);
    };

    socket.onerror = errorEvent => {
        console.log("error", errorEvent);
    };

    socket.onmessage = messageEvent => {
        let imageUrl = URL.createObjectURL(messageEvent.data);
        img.src = imageUrl;
    };
}

Hooks.ImageHook = {
    mounted() {
        connectToWebsocket(this.el)
        setInterval(() => {
            if (socket != null && socket.readyState == 3) {
                connectToWebsocket(this.el)
            }
        }, 5000)
    }
};


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

