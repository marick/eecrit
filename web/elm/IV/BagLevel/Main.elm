module IV.BagLevel.Main exposing (..)

import Animation
import IV.BagLevel.View as View
import IV.Types exposing (..)

--- Model

type alias Model =
  { style : Animation.State
  }

startingState : Model 
startingState =
  Model (Animation.style View.levelAnimatedProperties)

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
    , duration = duration
    }


dropLevel animation =
  let
    change = [Animation.toWith (easing 2000.0) View.droppedProperties]
  in
    Animation.interrupt change animation

    

update : Msg -> Model -> Model
update msg model =
  case msg of
    StartSimulation ->
      { model | style = dropLevel model.style }

    AnimationClockTick tick ->
      { model | style = (Animation.update tick) model.style }
