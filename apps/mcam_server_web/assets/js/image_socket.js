export class ImageSocket {
    constructor(img) {
        this.img = img;
        this.ws_url = img.dataset.binaryWsUrl;
    }

    connect() {
        console.log("connect", this.ws_url);
        this.hasErrored = false;
        this.socket = new WebSocket(this.ws_url);
        let that = this;
        this.socket.onopen = () => { that.onOpen(); }
        this.socket.onclose = () => { that.onClose(); }
        this.socket.onerror = errorEvent => { that.onError(errorEvent); };
        this.socket.onmessage = messageEvent => { that.onMessage(messageEvent); };
    }

    onOpen() {
        console.log("ws opened");
    }

    onClose() {
        this.maybeReopen();
        console.log("ws closed", this);
    }

    onError(errorEvent) {
        this.hasErrored = true;
        console.log("error", errorEvent);
    }

    onMessage(messageEvent) {
        let oldImageUrl = this.img.src;
        let imageUrl = URL.createObjectURL(messageEvent.data);
        this.img.src = imageUrl;

        if (oldImageUrl != "") {
            URL.revokeObjectURL(oldImageUrl);
        }
    }

    isSocketClosed() {
        return this.socket == null || this.socket.readyState == 3;
    };

    maybeReopen() {
        let after = this.hasErrored ? 2000 : 0;
        setTimeout(() => {
            if (this.isSocketClosed()) this.connect();
        }, after);
    };
}