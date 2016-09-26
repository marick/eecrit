module IV.Clock.Update exposing (..)

import Animation exposing (px)
import IV.Clock.Msg exposing (Msg(..))
import IV.Clock.Model as Model exposing (Model)
import IV.Clock.View as View
import Time exposing (second)
import IV.Types exposing (..)


spinCount n =
  Animation.easing
    {
      ease = identity
    , duration = n * 1.5 * second
    }

advanceHours hours animation = 
  let
    change  =
      [ Animation.toWith (spinCount 1) [Animation.rotate (Animation.deg 90)]
      , Animation.toWith (spinCount 1) [Animation.rotate (Animation.deg 120)]
      , Animation.toWith (spinCount 1) [Animation.rotate (Animation.deg 150)]
      , Animation.toWith (spinCount 1) [Animation.rotate (Animation.deg 180)]
      ]
  in
    Animation.interrupt change animation

spinMinutes animation =
  let
    change =
      [ Animation.toWith (spinCount 4) [Animation.rotate (Animation.turn 4.0)]
      ]
  in
    Animation.interrupt change animation
  

update : Msg -> Model -> Model
update msg model =
  case msg of
    AdvanceHours hours ->
      { model
        | hourHand = advanceHours 4 model.hourHand
        , minuteHand = spinMinutes model.minuteHand
      }

    AnimationClockTick tick ->
      { model
        | hourHand = (Animation.update tick) model.hourHand
        , minuteHand = (Animation.update tick) model.minuteHand
      }
