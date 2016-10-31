module IV.Scenario.View exposing
  ( viewScenarioChoices
  , viewCaseBackgroundEditor
  , viewTreatmentEditor
  )

import Html exposing (..)
import Html.Attributes as Attr
import IV.Scenario.Model exposing (EditableModel, scenario, cowBackground, calfBackground)
import IV.Scenario.DataExport as DataExport
import IV.Scenario.Msg exposing (Msg(..))
import IV.Msg as MainMsg
import Html.Events as Events
import IV.Pile.HtmlShorthand exposing (..)


-- Top row of buttons

viewScenarioChoices : EditableModel -> Html MainMsg.Msg    
viewScenarioChoices model =
  div []
    [ buttons model]

buttons model = 
  row []
  [ scenarioButton (scenario cowBackground) model ""
  , scenarioButton (scenario calfBackground) model "col-md-offset-2"
  , textButton [ Events.onClick (local OpenCaseBackgroundEditor) ] "Write your own"
  ]
  
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
    textButton
      [Events.onClick <| MainMsg.PickedScenario buttonScenario] 
      buttonScenario.background.tag

-- Case background editor
  
viewCaseBackgroundEditor model =
  let
    display =
      case model.caseBackgroundEditorOpen of 
        True -> "block"
        False -> "none"
  in 
    div
    [Attr.style
       [ ("border", "2px solid #AAA")
       , ("display", display)
       ]
    ]
    [ p [] [text "here is some text"]
    , p [] [text "here is some text"]
    , p [] [text "here is some text"]
    , row []
        [ textButton
            [ Events.onClick (local CloseCaseBackgroundEditor) ]
            "Close"
        ]
    ]

-- Treatment editor
    
description model =
  "You are presented with a " ++
  toString model.background.weightInPounds ++
  " lb " ++ model.background.animalDescription ++ ". You have " ++
  toString model.background.bagContentsInLiters ++
  " liters of fluid in a " ++ 
  model.background.bagType ++ "."

viewTreatmentEditor : EditableModel -> Html MainMsg.Msg
viewTreatmentEditor model =
  row []
    [ p [] [text <| description model ] 
    , p
        []
        [ text "Using your calculations, set the drip rate to "
        , input
            [ Attr.type' "text"
            -- , Attr.class "form-control col-xs-2"
            , Attr.value model.decisions.dripRate
            , Attr.size 6
            , Events.onInput (changedText ChangedDripText)
            , Events.onBlur <| (MainMsg.ChoseDripRate (DataExport.dripRate model))
            ]
            []
        , text "drops/sec, set the hours "
        , input
            [ Attr.type' "text"
            , Attr.value model.decisions.simulationHours
            , Attr.size 6
            , Events.onInput (changedText ChangedHoursText)
            ]
            []
        , text " and minutes "
        , input
            [ Attr.type' "text"
            , Attr.value model.decisions.simulationMinutes
            , Attr.size 6
            , Events.onInput (changedText ChangedMinutesText)
            ]
            []
        , text " until you plan to next look at the fluid level, then " 
        , button
            [ Events.onClick <| MainMsg.StartSimulation (DataExport.runnableModel model)
            , Attr.class "btn btn-default btn-xs"
            ]
            [ text "Start the Clock" ]
        ]
    , p []
      [ text "To start over, click one of the buttons at the top." ]
    ]



-- Private

changedText : (String -> Msg) -> String -> MainMsg.Msg
changedText msg string =
  local (msg string)

local : Msg -> MainMsg.Msg
local msg =
  MainMsg.ToScenario msg


textButton extraAttributes string =
  button
  ( [ Attr.class "btn col-sm-5"
    , Attr.type' "button"
    ] ++ extraAttributes
  )
  [ text string ]
  
