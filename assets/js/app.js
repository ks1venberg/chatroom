// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import * as storage from "./local_storage"

let Hooks = {}
Hooks.GetAllChatMessages = {
  mounted() {
    window.addEventListener(`phx:get_localstorage_msgs`, (e) => {
      const chat_id = e.detail.chat_id
      this.pushEventTo("#messages", "get_chat_msgs", storage.get_localstorage_msgs(chat_id))
    })
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})


// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Get the connection link to join chat 
window.addEventListener(`phx:connect_by_chat_id`, (e) => {
    navigator.clipboard.writeText(e.detail.link);
  })

window.addEventListener(`phx:get_chat_msgs`, (e) => {
  // Store e.detail.message in local storage
  let chat_messages = storage.get_localstorage_msgs(e.detail.chat_id) || []
  chat_messages.push(e.detail.body)
  storage.save_messages(e.detail.chat_id, chat_messages)
})

window.addEventListener(`phx:clear_msg_input`, (e) => {
  // Clear input after sending message
  document.getElementById(e.detail.field_id).value = ''
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

