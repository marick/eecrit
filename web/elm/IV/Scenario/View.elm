module IV.Scenario.View exposing (view)

import Html exposing (..)
import Html.Attributes as Attr
import IV.Scenario.Model exposing (Model)
import IV.Msg as TopMsg
import IV.Scenario.Msg as Msg
import Html.Events as Events

changeHandler : String -> TopMsg.Msg
changeHandler string =
  TopMsg.ToScenario (Msg.ChangedDripText string)

description model =
  "You are presented with a " ++
  toString model.weightInPounds ++
  " lb " ++ model.animalDescription ++ "."
      
    
view : Model -> Html TopMsg.Msg
view model =
  div
    []
    [ p
       []
       [text <| description model ]
    , p
       []
       [ text "Using your calculations, the drip rate "
       , input
           [ Attr.type' "text"
           -- , Attr.class "form-control col-xs-2"
           , Attr.value model.dripText
           , Attr.size 6
           , Events.onInput changeHandler]
           []
       , text " and the hours [TBD] and minutes [TBD] to check, then " 
       , button
           [ Events.onClick TopMsg.StartSimulation
           , Attr.class "btn btn-default btn-xs"
           ]
           [ text "Try it out" ]
       ]
    ]
    
