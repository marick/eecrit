module IV.Scenario.Main exposing (..)

import IV.Scenario.Msg exposing (..)
import IV.Scenario.Model exposing (..)
import IV.Types exposing (..)
import IV.Pile.ManagedStrings exposing (..)
import String
import IV.Msg as Out

-- Model

commonToAllScenarios =
  { dripText = "0"
  , simulationHoursText = "0"
  , simulationMinutesText = "0"
  , dropsPerMil = 15.0
  }

cowScenario : Model
cowScenario =
  { tag = "1560 lb. cow"
      
  , animalDescription = "3d lactation purebred Holstein"
  , weightInPounds = 1560
  , bagCapacityInLiters = 20
  , bagContentsInLiters = 19
  , bagType = "5-gallon carboy"
              
  -- Must be a better way
  , dripText = commonToAllScenarios.dripText
  , simulationHoursText = commonToAllScenarios.simulationHoursText
  , simulationMinutesText = commonToAllScenarios.simulationMinutesText
  , dropsPerMil = commonToAllScenarios.dropsPerMil
  }
  
calfScenario : Model
calfScenario = 
  { tag = "90 lb. heifer calf"

  , animalDescription = "10-day-old Hereford heifer calf"
  , weightInPounds = 90
  , bagCapacityInLiters = 2
  , bagContentsInLiters = 2
  , bagType = "2-liter bag"

  -- Must be a better way
  , dripText = commonToAllScenarios.dripText
  , simulationHoursText = commonToAllScenarios.simulationHoursText
  , simulationMinutesText = commonToAllScenarios.simulationMinutesText
  , dropsPerMil = commonToAllScenarios.dropsPerMil
  }

-- Update

update : Msg -> Model -> (Model, Cmd Out.Msg )
update msg model =
  case msg of
    ChangedDripText string ->
      updateWhen string isValidFloatString model dripText' 
    ChangedHoursText string ->
      updateWhen string isValidIntString model simulationHoursText'
    ChangedMinutesText string ->
      updateWhen string isValidIntString model simulationMinutesText'
                
dripText' model val =
  { model | dripText = val }
simulationHoursText' model val =
  { model | simulationHoursText = val }
simulationMinutesText' model val =
  { model | simulationMinutesText = val }
    
updateWhen : String -> (String -> Bool) -> Model -> (Model -> String -> Model) -> (Model, Cmd Out.Msg)
updateWhen candidate pred model updater =
  ( if pred candidate then
      updater model candidate
    else
      model
  , Cmd.none
  )
