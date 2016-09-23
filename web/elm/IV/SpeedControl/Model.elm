module IV.SpeedControl.Model exposing (..)

type alias Model =
  { string : String
  , float : Float
  }

startingState : Model
startingState = Model "800" 800.0
