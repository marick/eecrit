module IV.View exposing (view)

import Animation
import Html exposing (..)
import Html.Attributes exposing (..)
import Svg
import Svg.Attributes as SA
import IV.Pile.HtmlShorthand exposing (..)

import IV.Main exposing (Model)
import IV.Msg exposing (Msg)
import IV.Scenario.View as Scenario
import IV.Apparatus.View as Apparatus
import IV.Clock.View as Clock

graphics = {width = "400px", height = "400px"}


mainSvg contents  =
  row [] 
    [ hr [] []
    , Svg.svg
        [ SA.version "1.1"
        , SA.x "0"
        , SA.y "0"
        , SA.width graphics.width
        , SA.height graphics.height
        ]
        contents
    ]

view : Model -> Html Msg
view model =
  div [] 
    [ div [class "header clearfix"]
        [ Scenario.viewScenarioChoices model.scenario
        , h3 [class "text-muted"] [text "IV Worksheet"]
        ]
    , div [class "row marketing" ]
        [ div [ class "col-sm-6" ]
            [ text "foo" ]
        , div [ class "col-sm-6" ]
          [ text "bar" ]
        ]
    ]
  -- [ Scenario.viewScenarioChoices model.scenario
  -- , Scenario.viewCaseBackgroundEditor model.scenario
  -- , mainSvg (Apparatus.render model.apparatus ++ Clock.render model.clock)
  -- , Scenario.viewTreatmentEditor model.scenario
  -- ]
  
