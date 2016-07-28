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
import "phoenix_html"

import $ from "jquery"
import "jquery"
import "bootstrap-select"

// Original version had this note about next line:
// "Needed for tether or bootstrap..."
// Because I don't know how/when the problem would
// show up if it's required for bootstrap, I'm leaving
// it in.
global.jQuery = require("jquery")
global.bootstrap = require("bootstrap")

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"


const elmDiv = document.getElementById('elm-main');
const elmApp = Elm.Critter4Us.embed(elmDiv);
