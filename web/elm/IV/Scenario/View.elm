module IV.Scenario.View exposing (view)

import Html exposing (..)
import Html.Attributes as Attr
import IV.Scenario.Main exposing (Model, Msg(..))
import IV.Msg as TopMsg
import Html.Events as Events

changeHandler : String -> TopMsg.Msg
changeHandler string =
  TopMsg.ToScenario (ChangedDripText string)

description model =
  "You are presented with a " ++
  toString model.weightInPounds ++
  " lb " ++ model.animalDescription ++ ". You have " ++
  toString model.bagContentsInLiters ++
  " liters of fluid in a " ++ 
  model.bagType ++ "."
      
    
view : Model -> Html TopMsg.Msg
view model =
  div
    []
    [ p
       []
       [text <| description model ]
    , p
       []
       [ text "Using your calculations, set the drip rate "
       , input
           [ Attr.type' "text"
           -- , Attr.class "form-control col-xs-2"
           , Attr.value model.dripText
           , Attr.size 6
           , Events.onInput changeHandler
           ]
           []
       , text " and the hours "
       , input
           [ Attr.type' "text"
           , Attr.value (toString model.simulationInHours)
           , Attr.size 6
           ]
           []
       , text " and minutes "
       , input
           [ Attr.type' "text"
           , Attr.value "0"
           , Attr.size 6
           ]
           []
       , text "before you next look at the fluid level, then " 
       , button
           [ Events.onClick TopMsg.StartSimulation
           , Attr.class "btn btn-default btn-xs"
           ]
           [ text "Try it out" ]
       ]
    ]
    
