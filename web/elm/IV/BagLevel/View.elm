module IV.BagLevel.View exposing (..)

import Animation exposing (px)
import IV.Palette as Palette
import Svg exposing (..)
import Svg.Attributes exposing (..)

levelBaseProperties =
  [ fill "#d3d7cf"
  , x "0"
  , width "120"
  ]

levelAnimatedProperties =
  [ Animation.y 20
  , Animation.height (px 180)
  ]

droppedProperties = [Animation.y 80, Animation.height (px 120)]

render model =
  rect (Animation.render model.style ++ levelBaseProperties) []
