module Pile.HtmlShorthand exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events as Events
import Json.Decode as Json

-- TODO: handle opening in a new tab/window?
onClickWithoutPropagation msg = 
  Events.onWithOptions "click"
    { stopPropagation = False
    , preventDefault = True
    }
    (Json.succeed msg)


onEnter : msg -> Attribute msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg
            else
                Json.fail "not ENTER"
    in
        Events.on "keydown" (Events.keyCode |> Json.andThen isEnter)
