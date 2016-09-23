module IV.Droplet.Model exposing (Model, startingState, animation)

import Animation
import IV.Droplet.View as View

type alias Model =
  { style : Animation.State
  , currentSpeed : Float
  }

startingState : Model
startingState = Model (Animation.style View.starting) 800.0

animation : Model -> Animation.State
animation model =
  model.style
