module IV.Clock.Model exposing (..)

import Animation
import IV.Clock.View as View
import IV.Types exposing (..)

type alias Model =
  { hourHand : Animation.State
  , minuteHand : Animation.State
  }

startingState =
  { hourHand = Animation.style (View.hourHandStartsAt 2)
  , minuteHand = Animation.style (View.minuteHandStartsAt 0)
  }

animations : Model -> List Animation.State
animations model =
  [model.hourHand, model.minuteHand]
           
