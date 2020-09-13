const avatars = new Map();
let user;
let connectedUsers;

const BroadcastMovementHook = (scene) => ({
  mounted() {
    scene.camera.cameraObject.element.addEventListener(
      "move",
      ({ detail: coords }) => {
        this.pushEvent("move", {
          uuid: user,
          coords,
        });
      },
      false
    );

    // Handlers for presence and move
    this.handleEvent(
      "presence-changed",
      ({ presence_diff, presence, uuid }) => {
        if (user === undefined) {
          user = uuid;
        }
        const joins = Object.keys(presence_diff.joins);
        const leaves = Object.keys(presence_diff.leaves);

        connectedUsers = new Set(presence);

        leaves.forEach((leave) => {
          if (leave !== user) {
            const avatar = avatars.get(leave);
            scene.removeAvatar(avatar);
            avatars.delete(leave);
          }
        });
        joins.forEach((join) => {
          if (join !== user) {
            const newAvatar = scene.createAvatar("user");
            newAvatar.update();
            avatars.set(join, newAvatar);
          }
        });
      }
    );

    this.handleEvent("move", ({ movement }) => {
      const { coords, uuid } = movement;
      if (user !== uuid) {
        const updateAvatar = avatars.get(user);
        if (updateAvatar) {
          updateAvatar.translateX(coords.posX);
          updateAvatar.translateY(coords.posY);
          updateAvatar.translateZ(coords.posZ);
          // updateAvatar.rotateX(coords.rotX);
          // updateAvatar.rotateY(coords.rotY);
          // updateAvatar.rotateZ(coords.rotZ);
          updateAvatar.update();
        }
      }
    });
  },
});

export default BroadcastMovementHook;
