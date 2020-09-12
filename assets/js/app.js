import "../css/app.scss";

import "phoenix_html";
import { Socket, Presence } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";
import { Scene } from "3d-css-scene";

const scene = new Scene();
const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)

let Hooks = {};

Hooks.BroadcastMovement = {
  mounted() {
    const self = this;
    scene.camera.cameraObject.element.addEventListener(
      "move",
      function (event) {
        self.pushEvent("publish-move", event.detail);
      },
      false
    );
    this.handleEvent("presence-changed", (thing) =>
      console.log(JSON.stringify(thing, null, 2))
    );
  },
  update() {
    console.log("this was updated");
  },
};

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

liveSocket.connect();

const socket = liveSocket.getSocket();
console.log(socket);
console.log(socket.channels[0]);
window.liveSocket = liveSocket;

const room = scene.createRoom("room", 3600, 1080, 3000);
room.translateZ(-200);
room.update();
