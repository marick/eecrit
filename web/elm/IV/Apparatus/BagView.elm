module IV.Apparatus.BagView exposing
  ( view
  , startingState
  , startDraining
  , animationClockTick
  )

import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Pile.Animation exposing (AnimationState)
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

view animationState =
  Rect.render configuration C.bagOrigin animationState
    
startingState : Level -> AnimationState 
startingState level =
  Rect.startingState configuration level
    
startDraining : Drainage -> AnimationState -> (AnimationState, Cmd Msg)
startDraining drainage animationState =
  case drainage of
    FullyEmptied hours ->
      Rect.drainThenSend configuration hours animationState FluidRanOut

    PartlyEmptied hours level ->
      Rect.drainPartially configuration hours level animationState 

animationClockTick tick animationState = Rect.continueDraining tick animationState

-- The static part      

marking n =
  let
    ypos = 20 * n
  in
    line
      [ x1_ 0
      , x2_ 30
      , y1_ ypos
      , y2_ ypos
      , stroke "black" ]
    []

markings = Svg.g [] <| List.map marking (List.range 1 9)
