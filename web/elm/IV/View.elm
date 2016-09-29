module IV.View exposing (view)

import IV.Msg exposing (Msg)
import IV.Model exposing (Model)
import Html exposing (..)
import Html.Attributes as Attr
import IV.Droplet.View as Droplet
import IV.Scenario.View as Scenario
import IV.Clock.View as Clock
import Svg
import Svg.Attributes exposing (..)
import IV.View.Apparatus as Apparatus
import IV.View.ClockFace as ClockFace

everything = {width = "700px", height = "700px"}
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

mainSvg staticContents animatedContents  =
  Svg.svg
  [ version "1.1"
  , x "0"
  , y "0"
  , Svg.Attributes.width graphics.width
  , Svg.Attributes.height graphics.height
  ]
  (staticContents ++ animatedContents)

view : Model -> Html Msg
view model =
  mainDiv
  [ mainSvg
      [Apparatus.drawing, ClockFace.drawing]
      [Droplet.render model.droplet, Clock.render model.clock]
  , Scenario.view model.scenario
  ]
