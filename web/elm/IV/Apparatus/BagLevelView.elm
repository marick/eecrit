module IV.Apparatus.BagLevelView exposing ( render
                                          , animationProperties
                                          )

import Animation exposing (px)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Pile.SvgAttributes exposing (..)
import IV.Types exposing (..)

import IV.Apparatus.ViewConstants as Apparatus


render model =
  rect (Animation.render model ++ invariantProperties) []

animationProperties (Level fractionBagFilled) =
  let
    height = fractionBagFilled * Apparatus.bagHeight
    y = Apparatus.bagHeight - height
  in
    [ Animation.y y
    , Animation.height (px height)
    ]


-- Private    

invariantProperties =
  [ fill Apparatus.liquidColorString
  , x' 0
  , width' Apparatus.bagWidth
  ]
