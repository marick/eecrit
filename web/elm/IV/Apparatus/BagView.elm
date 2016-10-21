module IV.Apparatus.BagView exposing
  ( ..
  )

import IV.Apparatus.ViewConstants as Apparatus

import IV.Pile.SvgAttributes exposing (..)
import IV.Types exposing (..)

import Animation exposing (px)
import Svg exposing (..)
import Svg.Attributes exposing (..)


render model =
  [ rect (Animation.render model.bagLevel ++ invariantProperties) []
  , Svg.g
      []
      ([ bag ] ++ List.map marking [1 .. 9])
  ]

-- The static part      

bag = rect
      [ fill "none"
      , x' 0
      , y' 0
      , width' Apparatus.bagWidth
      , height' Apparatus.bagHeight
      , stroke "black"
      ]
      []

marking n =
  let
    ypos = 20 * n
  in
    line
      [ x1' 0
      , x2' 30
      , y1' ypos
      , y2' ypos
      , stroke "black" ]
    []

-- Animated Part




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
