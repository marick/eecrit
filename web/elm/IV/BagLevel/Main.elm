module IV.BagLevel.Main exposing (..)

import Animation
import IV.BagLevel.View as View
import IV.Types exposing (..)
import Time exposing (second)

--- Model

type alias Model =
  { style : Animation.State
  }

animations : Model -> List Animation.State
animations model =
  [model.style]

-- Msg

type Msg
  = StartSimulation Hours Level
  | AnimationClockTick Animation.Msg

-- Update

startingState : Level -> Model 
startingState level =
  { style = Animation.style <| View.animationProperties level }

update : Msg -> Model -> Model
update msg model =
  case msg of
    StartSimulation hours level ->
      { model | style = drainBag hours level model.style }

    AnimationClockTick tick ->
      { model | style = (Animation.update tick) model.style }



easing duration =
  Animation.easing
    {
      ease = identity
    , duration = duration * 1.5 * second
    }

drainBag : Hours -> Level -> Animation.State -> Animation.State
drainBag (Hours hours) level animation =
  let
    ease = (easing hours)
    change = [Animation.toWith ease (View.animationProperties level)]
  in
    Animation.interrupt change animation
