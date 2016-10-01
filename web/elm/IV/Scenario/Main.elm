module IV.Scenario.Main exposing (..)

import IV.Types exposing (..)
import IV.Pile.ManagedStrings exposing (..)
import String


type alias Model =
  { dripText : String
  , animalDescription : String
  , weightInPounds : Int
  , simulationHoursText : String
  , simulationMinutesText : String
  , bagCapacityInLiters : Float
  , bagContentsInLiters : Float
  , bagType : String
  , dropsPerMil : Float
  }

startingState : Model
startingState = 
  { dripText = "0"
  , animalDescription = "3d lactation purebred Holstein"
  , weightInPounds = 1560
  , simulationHoursText = "4"
  , simulationMinutesText = "0"
  , bagCapacityInLiters = 20
  , bagContentsInLiters = 19
  , bagType = "5-gallon carboy"
  , dropsPerMil = 15.0
  }

-- Msg

type Msg
  = ChangedDripText String
  | ChangedHoursText String
  | ChangedMinutesText String


-- Update


updateNextSpeed model nextString =
  if isValidFloatString nextString then
    {model | dripText = nextString }
  else
    model
  
updateHours model nextString =
  if isValidIntString nextString then
    {model | simulationHoursText = nextString }
  else
    model

updateMinutes model nextString = 
  if isValidIntString nextString then
    {model | simulationMinutesText = nextString }
  else
    model
  
update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangedDripText string ->
      updateNextSpeed model string
    ChangedHoursText string ->
      updateHours model string
    ChangedMinutesText string ->
      updateMinutes model string
