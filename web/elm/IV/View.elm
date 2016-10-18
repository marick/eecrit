module IV.View exposing (view)

import IV.Main exposing (Model)
import IV.Msg exposing (Msg)
import Html exposing (..)
import Html.Attributes as Attr
import IV.Apparatus.DropletView as Droplet
import IV.Scenario.View as Scenario
import IV.Clock.View as Clock
import IV.Apparatus.BagLevelView as BagLevel
import Svg
import Svg.Attributes exposing (..)
import IV.Apparatus.View as Apparatus
import IV.Clock.ClockFace as ClockFace
import IV.Pile.HtmlShorthand exposing (..)

everything = {width = "400px", height = "700px"}
graphics = {width = "400px", height = "400px"}

mainDiv : List (Html msg) -> Html msg
mainDiv contents = 
  div
  [ Attr.style [ ( "margin", "0px auto" )
               , ( "width", everything.width )
               , ( "height", everything.height )
               , ( "cursor", "pointer" )
               ]
  ]
  contents

mainSvg contents  =
  row 
    [ hr [] []
    , Svg.svg
        [ version "1.1"
        , x "0"
        , y "0"
        , Svg.Attributes.width graphics.width
        , Svg.Attributes.height graphics.height
        ]
        contents
    ]

view : Model -> Html Msg
view model =
  mainDiv
  [ Scenario.choices model.scenario
  , mainSvg
      [BagLevel.render model.bagLevel, Droplet.render model.droplet,
         Apparatus.drawing, ClockFace.drawing,
         Clock.render model.clock]
  , Scenario.view model.scenario
  ]
