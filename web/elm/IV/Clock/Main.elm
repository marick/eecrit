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
  = StartSimulation Float
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

advanceHourHand : Float -> Animation.State -> Animation.State
advanceHourHand fractionalHours animation = 
  let
    ease = (easeForHours fractionalHours)
    endPosition = (Animation.deg (hoursInDegrees (2 + fractionalHours)))
    change  =
      [ Animation.toWith ease [Animation.rotate endPosition]
      ]
  in
    Animation.interrupt change animation

-- Todo: No idea why this is float, given it's being handed a literal 4.
spinMinuteHand : Float -> Animation.State -> Animation.State
spinMinuteHand fractionalHours animation =
  let
    revolutions = Animation.deg <| fractionalHours * 360
    ease = (easeForHours fractionalHours)
    change = Animation.toWith ease [Animation.rotate revolutions]
  in
    Animation.interrupt [change] animation
  

update : Msg -> Model -> Model
update msg model =
  case msg of
    StartSimulation fractionalHours ->
      { model
        | hourHand = advanceHourHand fractionalHours model.hourHand
        , minuteHand = spinMinuteHand fractionalHours model.minuteHand
      }

    AnimationClockTick tick ->
      { model
        | hourHand = (Animation.update tick) model.hourHand
        , minuteHand = (Animation.update tick) model.minuteHand
      }
    
