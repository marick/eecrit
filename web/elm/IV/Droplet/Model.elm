module IV.Droplet.Model exposing (Model, startingState, animation)

import Animation
import IV.Droplet.View as View
import IV.Types exposing (..)

type alias Model =
  { style : Animation.State
  , currentSpeed : Float
  }

startingState : DropsPerSecond -> Model 
startingState (DropsPerSecond float) =
  Model (Animation.style View.starting) float

animation : Model -> Animation.State
animation model =
  model.style
