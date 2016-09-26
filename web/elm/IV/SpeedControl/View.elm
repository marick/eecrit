module IV.SpeedControl.View exposing (view)

import Html exposing (..)
import Html.Attributes as Attr
import IV.SpeedControl.Model exposing (Model)
import IV.Msg as TopMsg
import IV.SpeedControl.Msg as Msg
import Html.Events as Events

changeHandler : String -> TopMsg.Msg
changeHandler string =
  TopMsg.ToSpeedControl (Msg.ChangedTextField string)

view : Model -> Html TopMsg.Msg
view model =
  div
    []
    [ input [ Attr.value model.string, Events.onInput changeHandler] []
    , button [Events.onClick TopMsg.ChangeDripRate ] [ text "Go" ]
    , button [Events.onClick TopMsg.AdvanceHours ] [ text "Advance Hours"]
    ]

  
