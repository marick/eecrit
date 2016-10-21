module IV.Apparatus.StaticView exposing (render)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Pile.SvgAttributes exposing (..)
import IV.Apparatus.ViewConstants as Apparatus
import IV.Apparatus.BagView

render =
  Svg.g
    []
    [bottomLiquid, chamber, hose]
      

-- Private
      
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
