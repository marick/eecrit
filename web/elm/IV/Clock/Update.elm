module IV.Clock.Update exposing (..)

import Animation exposing (px)
import IV.Clock.Msg exposing (Msg(..))
import IV.Clock.Model as Model exposing (Model)
import IV.Clock.View as View
import Time exposing (second)
import IV.Types exposing (..)


easing duration =
  Animation.easing
    {
      ease = identity
    , duration = duration
    }

advanceHours hours animation = 
  let
    change  =
      [ Animation.toWith (easing (3.0 * second)) [Animation.rotate (Animation.deg 90)]
      , Animation.toWith (easing (3.0 * second)) [Animation.rotate (Animation.deg 120)]
      , Animation.toWith (easing (3.0 * second)) [Animation.rotate (Animation.deg 150)]
      , Animation.toWith (easing (3.0 * second)) [Animation.rotate (Animation.deg 180)]
      ]
  in
    Animation.interrupt change animation

spinMinutes animation =
  let
    change =
      [ Animation.toWith (easing (4 * 3.0 * second)) [Animation.rotate (Animation.turn 4.0)]
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
