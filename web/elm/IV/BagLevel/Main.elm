module IV.Droplet.Main exposing (..)

import Animation
import IV.BagLevel.View as View
import IV.Types exposing (..)

--- Model

type alias Model =
  { style : Animation.State
  }

startingState : Model 
startingState =
  Model (Animation.style View.full)

animations : Model -> List Animation.State
animations model =
  [model.style]

-- Msg

type Msg
  = StartSimulation DropsPerSecond
  | AnimationClockTick Animation.Msg

-- Update

easing duration =
  Animation.easing
    {
      ease = identity
    , duration = duration
    }


update : Msg -> Model -> Model
update msg model =
  case msg of
    StartSimulation perSecond ->
      { model | style = changeDropRate perSecond model.style }

    AnimationClockTick tick ->
      { model | style = (Animation.update tick) model.style }
