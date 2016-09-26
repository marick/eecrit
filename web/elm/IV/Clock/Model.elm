module IV.Clock.Model exposing (..)

import Animation
import IV.Clock.View as View
import IV.Types exposing (..)

type alias Model =
  { hourHand : Animation.State
  }

startingState =
  Model (Animation.style (View.hourHandStartsAt 2))

animations : Model -> List Animation.State
animations model =
  [model.hourHand]
           
