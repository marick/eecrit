module IV.Scenario.Main exposing (..)

import IV.Types exposing (..)
import IV.Pile.ManagedStrings exposing (..)
import String


type alias Model =
  { dripText : String
  , animalDescription : String
  , weightInPounds : Int
  , simulationInHours : Int
  , bagCapacityInLiters : Float
  , bagContentsInLiters : Float
  , bagType : String
  }

startingState : DropsPerSecond -> Model
startingState dropsPerSecond = 
  { dripText = "0"
  , animalDescription = "3d lactation purebred Holstein"
  , weightInPounds = 1560
  , simulationInHours = 1
  , bagCapacityInLiters = 20
  , bagContentsInLiters = 19
  , bagType = "5-gallon carboy"
  }

-- Msg

type Msg
  = ChangedDripText String


-- Update




updateNextSpeed model nextString =
  if isValidFloatString nextString then
    {model | dripText = nextString }
  else
    model
              
  
update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangedDripText string ->
      updateNextSpeed model string
