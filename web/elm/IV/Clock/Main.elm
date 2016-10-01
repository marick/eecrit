module IV.Clock.Main exposing (..)

import Animation
import IV.Clock.View as View
import IV.Types exposing (..)
import Time exposing (second)

-- Model

type alias Model =
  { hourHand : Animation.State
  , minuteHand : Animation.State
  }

startingState =
  { hourHand = Animation.style (View.hourHandStartsAt 2)
  , minuteHand = Animation.style (View.minuteHandStartsAt 0)
  }

animations : Model -> List Animation.State
animations model =
  [model.hourHand, model.minuteHand]
           
-- Msg

type Msg
  = StartSimulation Hours
  | AnimationClockTick Animation.Msg


-- Update  

easeForHours n =
  Animation.easing
    {
      ease = identity
    , duration = n * 1.5 * second
    }

startingHourDegrees = 60.0

hoursInDegrees : Float -> Float
hoursInDegrees hours = 30 * hours

advanceHourHand : Hours -> Animation.State -> Animation.State
advanceHourHand (Hours hours) animation = 
  let
    ease = (easeForHours hours)
    endPosition = (Animation.deg (hoursInDegrees (2 + hours)))
    change  =
      [ Animation.toWith ease [Animation.rotate endPosition]
      ]
  in
    Animation.interrupt change animation

spinMinuteHand : Hours -> Animation.State -> Animation.State
spinMinuteHand (Hours hours) animation =
  let
    revolutions = Animation.deg <| hours * 360
    ease = (easeForHours hours)
    change = Animation.toWith ease [Animation.rotate revolutions]
  in
    Animation.interrupt [change] animation
  

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
    
