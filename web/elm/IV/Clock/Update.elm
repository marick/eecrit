module IV.Clock.Update exposing (..)

import Animation exposing (px)
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

advanceHourHand hours animation = 
  let
    change  =
      [ Animation.toWith (easeForHours 1) [Animation.rotate (Animation.deg 90)]
      , Animation.toWith (easeForHours 1) [Animation.rotate (Animation.deg 120)]
      , Animation.toWith (easeForHours 1) [Animation.rotate (Animation.deg 150)]
      , Animation.toWith (easeForHours 1) [Animation.rotate (Animation.deg 180)]
      ]
  in
    Animation.interrupt change animation

-- Todo: No idea why this is float, given it's being handed a literal 4.
spinMinuteHand : Float -> Animation.State -> Animation.State
spinMinuteHand hours animation =
  let
    revolutions = Animation.deg <| hours * 360
    change = Animation.toWith (easeForHours hours) [Animation.rotate revolutions]
  in
    Animation.interrupt [change] animation
  

update : Msg -> Model -> Model
update msg model =
  case msg of
    StartSimulation ->
      { model
        | hourHand = advanceHourHand 4 model.hourHand
        , minuteHand = spinMinuteHand 4 model.minuteHand
      }

    AnimationClockTick tick ->
      { model
        | hourHand = (Animation.update tick) model.hourHand
        , minuteHand = (Animation.update tick) model.minuteHand
      }
