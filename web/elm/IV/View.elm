module IV.View exposing (view)

import IV.Msg exposing (Msg)
import IV.Model exposing (Model)
import Html exposing (..)
import Html.Attributes as Attr
import IV.Backdrop exposing (..)
import IV.Droplet.View as Droplet
import IV.SpeedControl.View as SpeedControl
import IV.Clock.View as Clock
import Svg
import Svg.Attributes exposing (..)

width = "700px"
height = "700px"
svgArea = "0 0 400 400"

mainDiv : List (Html msg) -> Html msg
mainDiv contents = 
  div
  [ Attr.style [ ( "margin", "0px auto" )
               , ( "width", width )
               , ( "height", height )
               , ( "cursor", "pointer" )
               ]
  ]
  contents

mainSvg contents =
  Svg.svg
  [ version "1.1"
  , x "0"
  , y "0"
  , viewBox svgArea
  ]
  contents

view : Model -> Html Msg
view model =
  mainDiv
  [ mainSvg (entireDrip ++ [Clock.face] ++ [ (Droplet.render model.droplet)
                           , (Clock.render model.clock)
                           ])
  , SpeedControl.view model.speedControl
  ]
