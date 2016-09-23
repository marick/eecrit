module IV.SpeedControl.Model exposing (..)

type alias Model =
  { string : String
  , float : Float
  }

startingState : String -> Float -> Model
startingState string float
  = Model string float
