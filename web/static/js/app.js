// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

var client = document.getElementById('client')
  , app = Elm.embed(Elm.Client, client, { connected: false, inbox: "", log: "" })

var connected = app.ports.connected.send
  , handle = app.ports.inbox.send
  , log = app.ports.log.send

import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.onOpen( () => console.log("socket open"))
socket.onClose( () => console.log("socket close"))
socket.onError( () => console.log("socket error"))

socket.connect()

let channel = socket.channel("chats:lobby", {})

channel.onClose( () => { connected(false), log("Connection closed") })
channel.onError( () => { connected(false), log("Connection dropped") })

channel.join()
  .receive("ok", resp => { connected(true), log("Connection established") })
  .receive("error", resp => { log("Unable to connect") })

function transport(payload) {
  channel.push("ping", payload)
    .receive("pong", ({payload}) => { handle(payload) })
    .receive("error", e => { console.log(e) })
}

app.ports.transport.subscribe(transport)
