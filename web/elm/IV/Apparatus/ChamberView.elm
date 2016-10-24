module IV.Apparatus.ChamberView exposing (render)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Animation exposing (px)
import IV.Pile.SvgAttributes exposing (..)
import IV.Apparatus.ViewConstants as C

render =
  Svg.g
    []
    [bottomFluid, chamber]
      

-- Private
      
chamber = rect
          [ fill "none"
          , stroke "black"
          , x' C.chamberXOffset
          , y' C.bagHeight
          , width' C.chamberWidth
          , height' C.chamberHeight
          ]
          []

-- animatableFluidAttributes =
--   [Animation.y 
            
bottomFluid = rect
               [ fill C.fluidColorString
               , x' C.chamberXOffset
               , y' (C.puddleYOffset + C.puddleHeight)
               , width' C.chamberWidth
               , height' C.puddleHeight
               ]
               []
