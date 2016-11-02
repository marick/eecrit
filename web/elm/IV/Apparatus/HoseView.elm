module IV.Apparatus.HoseView exposing
  ( view
  , startingState
  , startDraining
  , animationClockTick
  )

import IV.Apparatus.DrainingRectangle as Rect
import IV.Apparatus.ViewConstants as C
import IV.Types exposing (..)

configuration =
  { containerWidth = C.hoseWidth
  , containerHeight = C.hoseHeight
  , fillColor = C.fluidColorString
  , extraFigures = []
  }

view animationState =
  Rect.render configuration C.hoseOrigin animationState

startingState = Rect.startingState configuration (Level 1.0)
startDraining animationState = Rect.drain configuration (Hours 0.2) animationState
animationClockTick tick animationState = Rect.continueDraining tick animationState

