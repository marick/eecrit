module IV.SpeedControl.Model exposing (..)

type alias Model =
  { desiredNextSpeed : String }

startingState : Model
startingState = Model "800"
