module IV.Droplet.Model exposing (Model, startingState, animations)

import Animation
import IV.Droplet.View as View
import IV.Types exposing (..)

type alias Model =
  { style : Animation.State
  , currentSpeed : Float
  }

startingState : DropsPerSecond -> Model 
startingState (DropsPerSecond float) =
  Model (Animation.style View.missingDrop) float

animations : Model -> List Animation.State
animations model =
  [model.style]
