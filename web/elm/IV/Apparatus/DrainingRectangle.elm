module IV.Apparatus.DrainingRectangle exposing
 (..)
  -- ( render
  -- , startingState
  -- , drain
  -- , drainThenSend
  -- , continueDraining)

import Animation exposing (px)
import Animation.Messenger
import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Pile.Animation exposing (easeForHours, AnimationState)

import IV.Pile.SvgAttributes exposing (..)
import IV.Types exposing (..)

-- TODO: I hate hate hate how this state has to appear everywhere
import IV.Msg exposing (Msg)

type alias Configuration =
  { containerWidth : Int
  , containerHeight : Int
  , fillColor : String
  , extraFigures : List (Svg Msg)
  }

startingState : Configuration -> Level -> AnimationState
startingState configuration startingLevel =
  Animation.style <| animatableAttributes configuration startingLevel

render : Configuration -> Point -> AnimationState -> Svg Msg
render configuration origin animationState =
  Svg.g
    [ transform (translate origin) ]
    ([fluid animationState configuration, container configuration] ++ configuration.extraFigures)

drain : Configuration -> Hours -> AnimationState -> (AnimationState, Cmd Msg)
drain configuration hours animationState = 
  doDrain configuration hours (Level 0) animationState []

drainPartially : Configuration -> Hours -> Level -> AnimationState -> (AnimationState, Cmd Msg)
drainPartially configuration hours level animationState =
  doDrain configuration hours level animationState []

-- TODO: How to make this type annotation work without introducing a
-- dependency on IV.Msg?
-- drainThenSend : Configuration -> Hours -> AnimationState -> msg -> (AnimationState, Cmd msg)
drainThenSend configuration hours animationState msg =
  doDrain configuration hours (Level 0) animationState [ Animation.Messenger.send msg]

continueDraining tick animationState = 
  Animation.Messenger.update tick animationState

-- Private

doDrain configuration hours level animationState moreSteps =
  let
    drainStep = Animation.toWith
                  (easeForHours hours)
                  (animatableAttributes configuration level)
  in
  ( Animation.interrupt (drainStep :: moreSteps) animationState
  , Cmd.none
  )


container configuration = 
  rect
    [ fill "none"
    , stroke "black"
    , x' 0
    , y' 0
    , width' configuration.containerWidth
    , height' configuration.containerHeight
    ]
    []

fluid chamberFluid configuration =
  rect (Animation.render chamberFluid ++ fixedAttributes configuration) []
      
fixedAttributes configuration = 
               [ fill configuration.fillColor
               , x' 0
               , width' configuration.containerWidth
               ]
      
animatableAttributes configuration (Level level) =
  let
    height = level * (toFloat configuration.containerHeight)
    y = (toFloat configuration.containerHeight) - height
  in
    [ Animation.y y
    , Animation.height (px height)
    ]
