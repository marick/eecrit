module IV.Scenario.View exposing (choices, view)

import Html exposing (..)
import Html.Attributes as Attr
import IV.Scenario.Main exposing (Model, Msg(..), cowScenario, calfScenario)
import IV.Main as Main
import Html.Events as Events
import IV.Pile.HtmlShorthand exposing (..)

changeHandler : (String -> Msg) -> String -> Main.Msg
changeHandler msg string =
  Main.ToScenario (msg string)

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

scenarioButton : Model -> Model -> String -> Html Main.Msg
scenarioButton buttonScenario currentScenario additionalClassString =
  let 
    class = "btn col-sm-5 " ++
            highlight buttonScenario currentScenario ++
            additionalClassString
  in
    button 
      [ Attr.type' "button"
      , Attr.class class
      , Events.onClick <| Main.ToScenario <| PickedScenario buttonScenario
      ]
      [ text buttonScenario.tag]

choices : Model -> Html Main.Msg    
choices model = 
  row
    [ scenarioButton cowScenario model ""
    , scenarioButton calfScenario model "col-md-offset-2"
    ]
  
view : Model -> Html Main.Msg
view model =
  row
    [ p [] [text <| description model ] 
    , p
        []
        [ text "Using your calculations, set the drip rate "
        , input
            [ Attr.type' "text"
            -- , Attr.class "form-control col-xs-2"
            , Attr.value model.dripText
            , Attr.size 6
            , Events.onInput (changeHandler ChangedDripText)
            ]
            []
        , text " and the hours "
        , input
            [ Attr.type' "text"
            , Attr.value model.simulationHoursText
            , Attr.size 6
            , Events.onInput (changeHandler ChangedHoursText)
            ]
            []
        , text " and minutes "
        , input
            [ Attr.type' "text"
            , Attr.value model.simulationMinutesText
            , Attr.size 6
            , Events.onInput (changeHandler ChangedMinutesText)
            ]
            []
        , text "until you plan to next look at the fluid level, then " 
        , button
            [ Events.onClick Main.StartSimulation
            , Attr.class "btn btn-default btn-xs"
            ]
            [ text "See What To Expect" ]
        ]
    ]
