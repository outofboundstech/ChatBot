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

var bearer_token = docCookies.getItem("bearer_token") || (() => {
    // Make an xhr request to obtain a bearer token
    var resource = "/authenticate"
      , timeout = 2000 // Terminate after 2 secs.
      , xhr = new XMLHttpRequest()
    // See https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest
    // for comprehensive documentation of the XMLHttpRequest object
    xhr.open("POST", resource)
    xhr.timeout = timeout
    // xhr.ontimeout = function() {
    // };
    xhr.onreadystatechange = function() {
      if (4 == xhr.readyState && 200 == xhr.status) {
        var data = JSON.parse(xhr.responseText)
        docCookies.setItem("bearer_token",data.bearer_token)
        return data.bearer_token
      }
    }
    xhr.send()
  })()

let socket = new Socket("/socket", {params: {bearer_token: bearer_token}})

socket.onOpen( () => console.log("socket open"))
socket.onClose( () => console.log("socket close"))
socket.onError( () => console.log("socket error"))

socket.connect()

let channel = socket.channel("rooms:lobby", {})

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
