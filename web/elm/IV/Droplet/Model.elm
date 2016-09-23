module IV.Droplet.Model exposing (Model, startingState)

import Animation
import IV.Droplet.View as View

type alias Model =
  { style : Animation.State
  , currentSpeed : Float
  }

startingState : Model
startingState = Model (Animation.style View.starting) 800.0

