module IV.Scenario.Model exposing (..)

import IV.Types exposing (..)

type alias Model =
  { dripText : String
  , animalDescription : String
  , weightInPounds : Int
  , simulationInHours : Int
  }

startingState : DropsPerSecond -> Model
startingState dropsPerSecond = 
  { dripText = ""
  , animalDescription = "3d lactation purebred Holstein"
  , weightInPounds = 1560
  , simulationInHours = 1
  }

