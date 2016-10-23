module IV.Clock.Main exposing
  ( Model
  , animations
  , startingState
  , startSimulation
  , animationClockTick
  )

import Animation
import Animation.Messenger
import IV.Clock.AnimatedView as View
import IV.Types exposing (..)
import IV.Pile.Animation exposing (easeForHours)
import IV.Msg exposing (..)
import IV.Pile.CmdFlow as CmdFlow

animations : Model -> List AnimationState
animations model =
  [model.hourHand, model.minuteHand]
           
-- Model

startingHourRaw = 2
startingHour = Hours startingHourRaw

type alias Model =
  { hourHand : AnimationState
  , minuteHand : AnimationState
  }
hourHand' model val = { model | hourHand = val }
minuteHand' model val = { model | minuteHand = val }

hourHandPart = { getter = .hourHand, setter = hourHand' }
minuteHandPart = { getter = .minuteHand, setter = minuteHand' }


startingState =
  { hourHand = Animation.style (View.hourHandStartsAt startingHourRaw)
  , minuteHand = Animation.style (View.minuteHandStartsAt 0)
  }

-- Update

startSimulation hours model = 
  CmdFlow.chainLike model
    [ ( hourHandPart, advanceHourHand hours)
    , ( minuteHandPart, spinMinuteHand hours)
    ]

animationClockTick tick model =
  CmdFlow.chainLike model
    [ ( hourHandPart, Animation.Messenger.update tick )
    , ( minuteHandPart, Animation.Messenger.update tick )
    ]
  

-- Private

minuteHandRotations (Hours raw) =
  raw * 360

hourHandRotations (Hours raw) = 
  (startingHourRaw + raw) * 30 

advance animation hours rotationF endMsg = 
  let
    rotation = Animation.deg (rotationF hours)
    rotationStep = (Animation.toWith (easeForHours hours) [Animation.rotate rotation])
    after = case endMsg of
              Nothing -> []
              Just msg -> [Animation.Messenger.send msg]
    steps = rotationStep :: after
  in
    Animation.interrupt steps animation ! []
    
advanceHourHand : Hours -> AnimationState -> (AnimationState, Cmd Msg)
advanceHourHand hours animation = 
  advance animation hours hourHandRotations (Just StopSimulation)

spinMinuteHand : Hours -> AnimationState -> (AnimationState, Cmd Msg)
spinMinuteHand hours animation =
  advance animation hours minuteHandRotations Nothing

