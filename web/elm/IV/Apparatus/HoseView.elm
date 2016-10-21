module IV.Apparatus.HoseView exposing (render)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Pile.SvgAttributes exposing (..)
import IV.Apparatus.ViewConstants as Apparatus
  
render model =
  Svg.g
    []
    [hose]
      
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
