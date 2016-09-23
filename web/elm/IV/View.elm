module IV.View exposing (view)

import IV.Msg as TopMsg
import IV.Model exposing (Model)
import Html exposing (..)
import Html.Attributes as Attr
import IV.Backdrop exposing (provideBackdropFor)
import IV.Droplet.View as Droplet
import Html.Events as Events
import IV.SpeedControl.Msg exposing (Msg(ChangedTextField))

changeHandler : String -> TopMsg.Msg
changeHandler string =
  TopMsg.ToSpeedControl (ChangedTextField string)
                

view : Model -> Html TopMsg.Msg
view model =
    div
      [
       Attr.style [ ( "margin", "0px auto" ), ( "width", "500px" ), ( "height", "500px" ), ( "cursor", "pointer" ) ]
      ]
      [
        provideBackdropFor [(Droplet.render model.droplet)]
      , input [ Attr.value model.speedControl.string, Events.onInput changeHandler] []
      , button [Events.onClick TopMsg.ChangeDripRate ] [ text "Go" ]
      ]
