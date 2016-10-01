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
  = StartSimulation Float Level
  | AnimationClockTick Animation.Msg

-- Update

startingState : Level -> Model 
startingState level =
  { style = Animation.style <| View.animationProperties level }

update : Msg -> Model -> Model
update msg model =
  case msg of
    StartSimulation fractionalHours level ->
      { model | style = drainBag fractionalHours level model.style }

    AnimationClockTick tick ->
      { model | style = (Animation.update tick) model.style }



easing duration =
  Animation.easing
    {
      ease = identity
    , duration = duration * 1.5 * second
    }

drainBag : Float -> Level -> Animation.State -> Animation.State
drainBag fractionalHours level animation =
  let
    ease = (easing fractionalHours)
    change = [Animation.toWith ease (View.animationProperties level)]
  in
    Animation.interrupt change animation
