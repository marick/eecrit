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
      [ Animation.set View.startingHourHandProperties
      , Animation.toWith (easing (3.0 * second)) [Animation.rotate (Animation.deg 90)]
      , Animation.toWith (easing (3.0 * second)) [Animation.rotate (Animation.deg 120)]
      , Animation.toWith (easing (3.0 * second)) [Animation.rotate (Animation.deg 150)]
      , Animation.toWith (easing (3.0 * second)) [Animation.rotate (Animation.deg 180)]
      ]
    loop = Animation.repeat 4 change
  in
    Animation.interrupt change animation

update : Msg -> Model -> Model
update msg model =
  case msg of
    AdvanceHours hours ->
      { model | style = advanceHours 3.0 (Model.animation model) }

    AnimationClockTick tick ->
      { model | style = (Animation.update tick) (Model.animation model) }
