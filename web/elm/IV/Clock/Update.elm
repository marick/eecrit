module IV.Clock.Update exposing (..)

import Animation
import IV.Clock.Msg exposing (Msg(..))
import IV.Clock.Model as Model exposing (Model)
import IV.Clock.View as View
import Time exposing (second)
import IV.Types exposing (..)


easeForHours n =
  Animation.easing
    {
      ease = identity
    , duration = n * 1.5 * second
    }

startingHourDegrees = 60.0

hoursInDegrees : Float -> Float
hoursInDegrees hours = 30 * hours

fractionalHours hours minutes =
  hours + (minutes / 60.0)

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
    StartSimulation hours minutes ->
      let
        f = fractionalHours hours minutes
      in
      { model
        | hourHand = advanceHourHand f model.hourHand
        , minuteHand = spinMinuteHand f model.minuteHand
      }

    AnimationClockTick tick ->
      { model
        | hourHand = (Animation.update tick) model.hourHand
        , minuteHand = (Animation.update tick) model.minuteHand
      }
