import Video from "../video";

export const VideoPlayingHook = (playerContainer) => ({
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
    console.log("Updated?");
  },
})

export default VideoPlayingHook
