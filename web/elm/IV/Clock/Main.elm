module IV.Clock.Main exposing (..)

import Animation
import IV.Clock.View as View
import IV.Types exposing (..)
import IV.Pile.Animation as APile

-- Model

startingHour = Hours 2

type alias Model =
  { hourHand : Animation.State
  , minuteHand : Animation.State
  }

animations : Model -> List Animation.State
animations model =
  [model.hourHand, model.minuteHand]
           
-- Msg

type Msg
  = StartSimulation Hours
  | AnimationClockTick Animation.Msg


-- Update

startingState =
  { hourHand = Animation.style (View.hourHandStartsAt 2)
  , minuteHand = Animation.style (View.minuteHandStartsAt 0)
  }

update : Msg -> Model -> Model
update msg model =
  case msg of
    StartSimulation hours ->
      { model
        | hourHand = advanceHourHand hours model.hourHand
        , minuteHand = spinMinuteHand hours model.minuteHand
      }

    AnimationClockTick tick ->
      { model
        | hourHand = (Animation.update tick) model.hourHand
        , minuteHand = (Animation.update tick) model.minuteHand
      }
    



hoursInDegrees : Hours -> Float
hoursInDegrees (Hours hours) =
  30 * hours

    
minuteHandRotations (Hours hours) =
  Animation.deg <| hours * 360

advanceHourHand : Hours -> Animation.State -> Animation.State
advanceHourHand hours animation = 
  let
    ease = APile.easeForHours hours
    rotation = Animation.deg <| (hoursInDegrees startingHour) + hoursInDegrees hours
    change  =
      [ Animation.toWith ease [Animation.rotate rotation]
      ]
  in
    Animation.interrupt change animation

spinMinuteHand : Hours -> Animation.State -> Animation.State
spinMinuteHand hours animation =
  let
    revolutions = minuteHandRotations hours
    ease = APile.easeForHours hours
    change = Animation.toWith ease [Animation.rotate revolutions]
  in
    Animation.interrupt [change] animation
  

