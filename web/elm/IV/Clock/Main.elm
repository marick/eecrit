module IV.Clock.Main exposing
  ( Model
  , animations
  , startingState
  , startSimulation
  , animationClockTick
  )

import Animation
import Animation.Messenger
import IV.Clock.View as View
import IV.Clock.Lenses exposing (..)
import IV.Types exposing (..)
import IV.Pile.Animation exposing (easeForHours, AnimationState)
import IV.Msg exposing (..)

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

startingState =
  { hourHand = Animation.style (View.hourHandStartsAt startingHourRaw)
  , minuteHand = Animation.style (View.minuteHandStartsAt 0)
  }

-- Update

startSimulation hours model =
  flow model
    |> updateHourHand (advanceHourHand hours)
    |> updateMinuteHand (spinMinuteHand hours)

animationClockTick tick model =
  flow model
    |> updateHourHand (Animation.Messenger.update tick)
    |> updateMinuteHand (Animation.Messenger.update tick)

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

