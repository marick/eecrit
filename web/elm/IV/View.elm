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
    [ Svg.svg
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
    , Scenario.viewCaseBackgroundEditor model.scenario
    , div [class "row" ]
        [ div [ class "col-sm-7" ]
            [ mainSvg (Apparatus.render model.apparatus ++ Clock.render model.clock)
            ]
        , div [ class "col-sm-5" ]
          [ Scenario.viewTreatmentEditor model.scenario
          ]
        ]
    ]
