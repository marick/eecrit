module IV.Apparatus.ChamberView exposing (render)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Pile.SvgAttributes exposing (..)
import IV.Apparatus.ViewConstants as Apparatus

render =
  Svg.g
    []
    [bottomLiquid, chamber]
      

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
           
