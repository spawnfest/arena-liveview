const BroadcastMovementHook = (scene) => ({
  mounted() {
    scene.camera.cameraObject.element.addEventListener(
      "move",
      ({ detail: coords }) => {
        this.pushEvent("move", {
          user: scene.me,
          coords,
        });
      },
      false
    );

    // Handlers for presence and move
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
});

export default BroadcastMovementHook;
