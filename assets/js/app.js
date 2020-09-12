import "../css/app.scss";

import "phoenix_html";
import { Socket, Presence } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";
import { Scene } from "3d-css-scene";
import Video from "./video"

const scene = new Scene();
const room = scene.createRoom("room", 3600, 1080, 3000);

// This element should be captured and inserted before any side-effect during
// liveview hooks. For some reason, an appended element bugs the DOM whenever
// it's being manipulated during a hook life-cycle.
const playerContainer = document.getElementById('player-container')
playerContainer && room.north.insert(playerContainer)

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

Hooks.VideoPlaying = {
  mounted() {
    const { videoId, videoTime } = this.el.dataset
    videoId && Video.init(playerContainer, videoId, (player) => {
      player.target.playVideo()
      player.target.seekTo(videoTime)

      setInterval(() => {
        const currentTime = player.target.getCurrentTime()
        this.pushEvent('video-time-sync', currentTime)
      }, 3000)
    })
  },
  updated() {
    console.log('Updated?')
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

liveSocket.connect();

const socket = liveSocket.getSocket();
console.log(socket);
console.log(socket.channels[0]);
window.liveSocket = liveSocket;

room.translateZ(-200);
room.update();
