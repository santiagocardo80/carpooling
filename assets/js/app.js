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
import topbar from "topbar"
import { LiveSocket } from "phoenix_live_view"

const setPosition = ({ coords }) => {
  const x = document.getElementById("current-position")
  x.value = coords.latitude + "," + coords.longitude
}

const Hooks = {
  SetCurrentPosition: {
    mounted() {
      if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(setPosition)
      }
    }
  },
  SetCurrentDateTime: {
    mounted() {
      const currentDatetime = document.getElementById("current-datetime")
      const [date, time] = new Date()
        .toLocaleString("en-GB", { hour12: false })
        .split(', ')

      const [day, month, year] = date.split('/')
      currentDatetime.value = `${year}-${month}-${day} ${time}Z`
    }
  }
}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken }
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
