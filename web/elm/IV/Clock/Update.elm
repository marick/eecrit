module IV.Clock.Update exposing (..)

import Animation
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
      [ Animation.toWith (easing (3.0 * second)) View.startingHourHandProperties
      , Animation.toWith (easing (3.0 * second)) View.endingHourHandProperties
      ]
    loop = Animation.loop change
  in
    Animation.interrupt [loop] animation

update : Msg -> Model -> Model
update msg model =
  case msg of
    AdvanceHours hours ->
      { model | style = advanceHours 3.0 (Model.animation model) }

    AnimationClockTick tick ->
      { model | style = (Animation.update tick) (Model.animation model) }
