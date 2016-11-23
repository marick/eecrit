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

