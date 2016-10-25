module IV.Apparatus.DrainingRectangle exposing
  ( render
  , startingState
  , startDraining
  , continueDraining)

import Animation exposing (px)
import Animation.Messenger
import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Pile.Animation exposing (easeForHours)

import IV.Pile.SvgAttributes exposing (..)
import IV.Types exposing (..)

type alias Configuration =
  { containerWidth : Int
  , containerHeight : Int
  , fillColor : String
  }

startingState : Configuration -> Level -> AnimationState
startingState configuration startingLevel =
  Animation.style <| animatableAttributes configuration startingLevel

render : Configuration -> Point -> AnimationState -> Svg msg
render configuration origin animationState =
  Svg.g
    [ transform (translate origin) ]
    [fluid animationState configuration, container configuration]

startDraining : Configuration -> AnimationState -> (AnimationState, Cmd msg)
startDraining configuration model = 
    Animation.interrupt
    [ Animation.toWith
        (easeForHours (Hours 0.1))
        (animatableAttributes configuration (Level 0))
    ]
    model ! []

continueDraining tick model = 
  Animation.Messenger.update tick model

-- Private

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
