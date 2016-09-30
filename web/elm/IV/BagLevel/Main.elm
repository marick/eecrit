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
  = StartSimulation
  | AnimationClockTick Animation.Msg

-- Update

easing duration =
  Animation.easing
    {
      ease = identity
    , duration = duration * 1.5 * second
    }


dropLevel animation =
  let
    change = [Animation.toWith (easing 4) (View.animatedLevelValues 0.5)]
  in
    Animation.interrupt change animation

    

update : Msg -> Model -> Model
update msg model =
  case msg of
    StartSimulation ->
      { model | style = dropLevel model.style }

    AnimationClockTick tick ->
      { model | style = (Animation.update tick) model.style }
