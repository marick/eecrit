module IV.Apparatus.ChamberView exposing
  ( render
  , startingState
  , startDraining
  , animationClockTick)

import IV.Apparatus.DrainingRectangle as Rect
import IV.Apparatus.ViewConstants as C
import IV.Types exposing (..)

startingLevel = Level <| (toFloat C.puddleHeight) / (toFloat C.chamberHeight)
      
configuration =
  { containerWidth = C.chamberWidth
  , containerHeight = C.chamberHeight
  , fillColor = C.fluidColorString
  , extraFigures = []
  }

render animationState =
  Rect.render configuration C.chamberOrigin animationState

startingState = Rect.startingState configuration startingLevel
startDraining animationState = Rect.drain configuration (Hours 0.2) animationState
animationClockTick tick animationState = Rect.continueDraining tick animationState
