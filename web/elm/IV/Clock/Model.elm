module IV.Clock.Model exposing (..)

import Animation
import IV.Clock.View as View
import IV.Types exposing (..)

type alias Model =
  { style : Animation.State
  }

startingState =
  Model (Animation.style View.startingHourHandProperties)

animations : Model -> List Animation.State
animations model =
  [model.style]
           
