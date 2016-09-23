module IV.Droplet.Model exposing (Model, startingState, animation)

import Animation
import IV.Droplet.View as View

type alias Model =
  { style : Animation.State
  , currentSpeed : Float
  }

startingState : Float -> Model 
startingState float =
  Model (Animation.style View.starting) float

animation : Model -> Animation.State
animation model =
  model.style
