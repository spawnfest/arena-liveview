const BroadcastMovementHook = (scene) => ({
  mounted() {
    const { user, users: _users } = this.el.dataset
    const users = JSON.parse(_users)
    const avatars = new Map();

    users.forEach(user => {
      avatars.set(user, scene.createAvatar(user))
    })

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
        const joins = Object.keys(presence_diff.joins);
        const leaves = Object.keys(presence_diff.leaves);

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
        const avatar = avatars.get(uuid);

        if (avatar) {
          avatar.translateX(coords.posX);
          avatar.translateY(coords.posY);
          avatar.translateZ(coords.posZ);
          // avatar.rotateX(coords.rotX);
          // avatar.rotateY(coords.rotY);
          // avatar.rotateZ(coords.rotZ);
          avatar.update();
        }
      }
    });
  },
});

export default BroadcastMovementHook;
