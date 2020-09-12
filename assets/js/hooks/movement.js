const BroadcastMovement = {
  mounted() {
    const self = this;
    scene.camera.cameraObject.element.addEventListener(
      "move",
      function (event) {
        self.pushEvent("move", event.detail);
      },
      false
    );
    this.handleEvent("presence-changed", (thing) =>
      console.log(JSON.stringify(thing, null, 2))
    );
    this.handleEvent("move", (thing) =>
      console.log(JSON.stringify(thing, null, 2))
    );
  },
  update() {
    console.log("this was updated");
  },
};

export default BroadcastMovement;
