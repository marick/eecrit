module IV.Apparatus.BagView exposing
  ( render
  , startingState
  , startDraining
  , animationClockTick
  )

import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Pile.SvgAttributes exposing (..)

import IV.Apparatus.DrainingRectangle as Rect
import IV.Apparatus.ViewConstants as C
import IV.Msg exposing (Msg(..))
import IV.Types exposing (..)

configuration =
  { containerWidth = C.bagWidth
  , containerHeight = C.bagHeight
  , fillColor = C.fluidColorString
  , extraFigures = [markings]
  }

render animationState =
  Rect.render configuration C.bagOrigin animationState
    
startingState : Level -> AnimationState 
startingState level =
  Rect.startingState configuration level

-- Private
    
animationClockTick tick animationState = Rect.continueDraining tick animationState

startDraining : Drainage -> AnimationState -> (AnimationState, Cmd Msg)
startDraining drainage animationState =
  case drainage of
    FullyEmptied hours ->
      Rect.drainThenSend configuration hours animationState FluidRanOut

    PartlyEmptied hours level ->
      Rect.drainPartially configuration hours level animationState 

-- The static part      

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

markings = Svg.g [] <| List.map marking [1 .. 9]
