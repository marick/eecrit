module IV.Scenario.DataExport exposing
  ( SimulationData
  , runnableModel
  , dripRate
  , startingLevel
  )

import IV.Types exposing (..)
import IV.Pile.ManagedStrings exposing (floatString)
import IV.Scenario.Model exposing (..)

-- Here is what the rest of the world cares about

type alias SimulationData =
  { totalHours : Hours
  , drainage : Drainage
  }

runnableModel editableModel =
  let
    floats = toFloats editableModel
  in
    { totalHours = Hours (hours floats)
    , drainage = drainage floats
    }

dripRate : EditableModel -> DropsPerSecond  
dripRate editableModel =
  DropsPerSecond <| floatString editableModel.decisions.dripRate

startingLevel : EditableModel -> Level
startingLevel editableModel =
  let
    floats = toFloats editableModel
  in
    Level (floats.bagContentsInLiters / floats.bagCapacityInLiters)


-- Private

type alias DataAsFloats =
  { bagCapacityInLiters : Float
  , bagContentsInLiters : Float
  , dropsPerMil : Float
  , dripRate : Float
  , simulationHours : Float
  , simulationMinutes : Float
  }

toFloats : EditableModel -> DataAsFloats
toFloats stringContainer = 
  { bagCapacityInLiters = stringContainer.background.bagCapacityInLiters |> floatString
  , bagContentsInLiters = stringContainer.background.bagContentsInLiters |> floatString
  , dropsPerMil = stringContainer.background.dropsPerMil |> floatString
  , dripRate = stringContainer.decisions.dripRate |> floatString
  , simulationHours = stringContainer.decisions.simulationHours |> floatString
  , simulationMinutes = stringContainer.decisions.simulationMinutes |> floatString
  }

drainage : DataAsFloats -> Drainage
drainage floats =
  let 
    toEmpty = hoursToEmptyBag floats
    planned = hours floats
  in
    if planned < toEmpty then
      PartlyEmptied (Hours planned) (Level (endingFractionBagFilled floats))
    else
      FullyEmptied (Hours toEmpty)


-- Util

hours : DataAsFloats -> Float
hours floats =
  let
    h = floats.simulationHours
    m = floats.simulationMinutes
  in
    h + (m / 60.0)


hoursToEmptyBag : DataAsFloats -> Float
hoursToEmptyBag floats =
  floats.bagContentsInLiters / (litersPerHour floats)
      
endingFractionBagFilled : DataAsFloats -> Float
endingFractionBagFilled floats =
  let
    litersGone = (litersPerHour floats) * (hours floats)
  in
    (floats.bagContentsInLiters - litersGone) / floats.bagCapacityInLiters

litersPerHour : DataAsFloats -> Float
litersPerHour floats =
  let 
    milsPerSecond = floats.dripRate / floats.dropsPerMil
    milsPerHour = milsPerSecond * 60 * 60
  in
    milsPerHour / 1000
