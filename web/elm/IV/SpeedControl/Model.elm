module IV.SpeedControl.Model exposing (..)

import IV.Types exposing (..)

type alias Model =
  { string : String
  , perSecond : DropsPerSecond
  }

startingState : DropsPerSecond -> Model
startingState (DropsPerSecond float)
  = Model (toString float) (DropsPerSecond float)
