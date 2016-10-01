module IV.BagLevel.Main exposing (..)

import Animation
import IV.BagLevel.View as View
import IV.Types exposing (..)
import Time exposing (second)

--- Model

type alias Model =
  { style : Animation.State
  }

startingState : Float -> Model 
startingState fractionBagFilled =
  let
    startingProperties = View.animatedLevelValues fractionBagFilled
  in
    { style = Animation.style startingProperties }

animations : Model -> List Animation.State
animations model =
  [model.style]

-- Msg

type Msg
  = StartSimulation Float Float
  | AnimationClockTick Animation.Msg

-- Update

easing duration =
  Animation.easing
    {
      ease = identity
    , duration = duration * 1.5 * second
    }

dropLevel fractionalHours level animation =
  let
    ease = (easing fractionalHours)
    change = [Animation.toWith ease (View.animatedLevelValues level)]
  in
    Animation.interrupt change animation

    

update : Msg -> Model -> Model
update msg model =
  case msg of
    StartSimulation fractionalHours level ->
      { model | style = dropLevel fractionalHours level model.style }

    AnimationClockTick tick ->
      { model | style = (Animation.update tick) model.style }
