module IV.Apparatus.StaticView exposing (render)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Pile.SvgAttributes exposing (..)
import IV.Apparatus.ViewConstants as Apparatus

render =
  Svg.g
    []
    ([bottomLiquid, bag, chamber, hose] ++
       List.map marking [1 .. 9])
      

-- Private
      
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

chamber = polyline
          [ fill "none"
          , stroke "black"
          , points Apparatus.chamberPoints
          ]
          []

bottomLiquid = polygon
               [ fill Apparatus.liquidColorString
               , points Apparatus.chamberPuddlePoints
               ]
               []
           
hose =
  Svg.rect
    [ stroke "black"
    , fill Apparatus.liquidColorString
    , x' Apparatus.hoseXOffset
    , y' Apparatus.hoseYOffset
    , width' Apparatus.hoseWidth
    , height' Apparatus.hoseHeight
    ]
    []
