module IV.Clock.Main exposing (..)

import Animation
import Animation.Messenger
import IV.Clock.AnimatedView as View
import IV.Types exposing (..)
import IV.Pile.Animation as APile
import IV.Msg exposing (..)

-- Model

startingHour = Hours 2

type alias AnimationState =
  Animation.Messenger.State Msg

type alias Model =
  { hourHand : AnimationState
  , minuteHand : AnimationState
  }

animations : Model -> List AnimationState
animations model =
  [model.hourHand, model.minuteHand]
           

startingState =
  { hourHand = Animation.style (View.hourHandStartsAt 2)
  , minuteHand = Animation.style (View.minuteHandStartsAt 0)
  }

-- Update
  
startSimulation hours model = 
  ( { model
      | hourHand = advanceHourHand hours model.hourHand
      , minuteHand = spinMinuteHand hours model.minuteHand
    }
  , Cmd.none
  )

animationClockTick tick model =
  let
    (newHourHand, hourHandCommand) = Animation.Messenger.update tick model.hourHand
    (newMinuteHand, minuteHandCommand) = Animation.Messenger.update tick model.minuteHand
  in
  ( { model
      | hourHand = newHourHand
      , minuteHand = newMinuteHand
    }
  , Cmd.batch [hourHandCommand, minuteHandCommand]
  )
  



hoursInDegrees : Hours -> Float
hoursInDegrees (Hours hours) =
  30 * hours

    
minuteHandRotations (Hours hours) =
  Animation.deg <| hours * 360

advanceHourHand : Hours -> AnimationState -> AnimationState
advanceHourHand hours animation = 
  let
    ease = APile.easeForHours hours
    rotation = Animation.deg <| (hoursInDegrees startingHour) + hoursInDegrees hours
    change  =
      [ Animation.toWith ease [Animation.rotate rotation]
      , Animation.Messenger.send StopSimulation
      ]
  in
    Animation.interrupt change animation

spinMinuteHand : Hours -> AnimationState -> AnimationState
spinMinuteHand hours animation =
  let
    revolutions = minuteHandRotations hours
    ease = APile.easeForHours hours
    change = Animation.toWith ease [Animation.rotate revolutions]
  in
    Animation.interrupt [change] animation
  

