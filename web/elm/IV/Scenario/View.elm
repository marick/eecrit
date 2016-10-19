module IV.Scenario.View exposing (choices, view)

import Html exposing (..)
import Html.Attributes as Attr
import IV.Scenario.Model exposing (Model)
import IV.Scenario.Main exposing (cowScenario, calfScenario)
import IV.Scenario.Msg exposing (Msg(..))
import IV.Msg as MainMsg
import Html.Events as Events
import IV.Pile.HtmlShorthand exposing (..)

changedText : (String -> Msg) -> String -> MainMsg.Msg
changedText msg string =
  MainMsg.ToScenario (msg string)

description model =
  "You are presented with a " ++
  toString model.weightInPounds ++
  " lb " ++ model.animalDescription ++ ". You have " ++
  toString model.bagContentsInLiters ++
  " liters of fluid in a " ++ 
  model.bagType ++ "."

highlight buttonScenario currentScenario =
  if buttonScenario == currentScenario then
    " btn-primary "
  else
    " btn-default "

scenarioButton : Model -> Model -> String -> Html MainMsg.Msg
scenarioButton buttonScenario currentScenario additionalClassString =
  let 
    class = "btn col-sm-5 " ++
            highlight buttonScenario currentScenario ++
            additionalClassString
  in
    button 
      [ Attr.type' "button"
      , Attr.class class
      , Events.onClick <| MainMsg.PickedScenario buttonScenario
      ]
      [ text buttonScenario.tag]

choices : Model -> Html MainMsg.Msg    
choices model = 
  row
    [ scenarioButton cowScenario model ""
    , scenarioButton calfScenario model "col-md-offset-2"
    ]
  
view : Model -> Html MainMsg.Msg
view model =
  row
    [ p [] [text <| description model ] 
    , p
        []
        [ text "Using your calculations, set the drip rate to "
        , input
            [ Attr.type' "text"
            -- , Attr.class "form-control col-xs-2"
            , Attr.value model.dripText
            , Attr.size 6
            , Events.onInput (changedText ChangedDripText)
            , Events.onBlur <| MainMsg.ChoseDripSpeed 
            ]
            []
        , text "drops/sec, set the hours "
        , input
            [ Attr.type' "text"
            , Attr.value model.simulationHoursText
            , Attr.size 6
            , Events.onInput (changedText ChangedHoursText)
            ]
            []
        , text " and minutes "
        , input
            [ Attr.type' "text"
            , Attr.value model.simulationMinutesText
            , Attr.size 6
            , Events.onInput (changedText ChangedMinutesText)
            ]
            []
        , text " until you plan to next look at the fluid level, then " 
        , button
            [ Events.onClick MainMsg.StartSimulation
            , Attr.class "btn btn-default btn-xs"
            ]
            [ text "See What To Expect" ]
        ]
    ]
