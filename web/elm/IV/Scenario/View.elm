module IV.Scenario.View exposing (choices, view)

import Html exposing (..)
import Html.Attributes as Attr
import IV.Scenario.Models exposing (EditableModel, scenario, cowBackground, calfBackground, dripRate, runnableModel)
import IV.Scenario.Msg exposing (Msg(..))
import IV.Msg as MainMsg
import Html.Events as Events
import IV.Pile.HtmlShorthand exposing (..)
import IV.Scenario.Editor as Editor

changedText : (String -> Msg) -> String -> MainMsg.Msg
changedText msg string =
  MainMsg.ToScenario (msg string)

description model =
  "You are presented with a " ++
  toString model.background.weightInPounds ++
  " lb " ++ model.background.animalDescription ++ ". You have " ++
  toString model.background.bagContentsInLiters ++
  " liters of fluid in a " ++ 
  model.background.bagType ++ "."

highlight buttonScenario currentScenario =
  if buttonScenario == currentScenario then
    " btn-primary "
  else
    " btn-default "

scenarioButton : EditableModel -> EditableModel -> String -> Html MainMsg.Msg
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
      [ text buttonScenario.background.tag]

choices : EditableModel -> Html MainMsg.Msg    
choices model =
  div []
    [ buttons model
    , Editor.edit model
    ]

buttons model = 
  row []
  [ scenarioButton (scenario cowBackground) model ""
  , scenarioButton (scenario calfBackground) model "col-md-offset-2"
  ]  

view : EditableModel -> Html MainMsg.Msg
view model =
  row []
    [ p [] [text <| description model ] 
    , p
        []
        [ text "Using your calculations, set the drip rate to "
        , input
            [ Attr.type' "text"
            -- , Attr.class "form-control col-xs-2"
            , Attr.value model.decisions.dripText
            , Attr.size 6
            , Events.onInput (changedText ChangedDripText)
            , Events.onBlur <| (MainMsg.ChoseDripRate (dripRate model))
            ]
            []
        , text "drops/sec, set the hours "
        , input
            [ Attr.type' "text"
            , Attr.value model.decisions.simulationHoursText
            , Attr.size 6
            , Events.onInput (changedText ChangedHoursText)
            ]
            []
        , text " and minutes "
        , input
            [ Attr.type' "text"
            , Attr.value model.decisions.simulationMinutesText
            , Attr.size 6
            , Events.onInput (changedText ChangedMinutesText)
            ]
            []
        , text " until you plan to next look at the fluid level, then " 
        , button
            [ Events.onClick <| MainMsg.StartSimulation (runnableModel model)
            , Attr.class "btn btn-default btn-xs"
            ]
            [ text "Start the Clock" ]
        ]
    , p []
      [ text "To start over, click one of the buttons at the top." ]
    ]
