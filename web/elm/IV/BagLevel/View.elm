module IV.BagLevel.View exposing (..)

import Animation exposing (px)
import IV.Palette as Palette
import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Types exposing (..)

levelBaseProperties =
  [ fill "#d3d7cf"
  , x "0"
  , width "120"
  ]


animationProperties (Level fractionBagFilled) =
  let
    height = fractionBagFilled * 200
    y = 200 - height
  in
    [ Animation.y y
    , Animation.height (px height)
    ]

droppedProperties = [Animation.y 80, Animation.height (px 120)]

render model =
  rect (Animation.render model.style ++ levelBaseProperties) []
