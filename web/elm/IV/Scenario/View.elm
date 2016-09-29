module IV.Scenario.View exposing (view)

import Html exposing (..)
import Html.Attributes as Attr
import IV.Scenario.Model exposing (Model)
import IV.Msg as TopMsg
import IV.Scenario.Msg as Msg
import Html.Events as Events

changeHandler : String -> TopMsg.Msg
changeHandler string =
  TopMsg.ToScenario (Msg.ChangedTextField string)

view : Model -> Html TopMsg.Msg
view model =
  div
    [Attr.class "form-group"]
    [ label
        [ Attr.class "control-label" ]
        [text "Change drip rate  "]

    , input
        [ Attr.type' "text"
        -- , Attr.class "form-control col-xs-2"
        , Attr.value model.drip.string
        , Attr.size 4
        , Events.onInput changeHandler]
        []
    , button
        [ Events.onClick TopMsg.StartSimulation
        , Attr.class "btn btn-default btn-xs"
        ]
        [ text "Try it out!" ]
    ]
