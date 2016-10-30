module IV.Scenario.DataExport exposing (..)

import IV.Types exposing (..)
import IV.Pile.ManagedStrings exposing (floatString)
import IV.Scenario.Model exposing (..)

-- Runnable models

type alias RunnableModel =
  { totalHours : Hours
  , drainage : Drainage
  }

runnableModel editableModel =
  { totalHours = Hours <| hours editableModel
  , drainage = drainage editableModel
  }

dripRate : EditableModel -> DropsPerSecond  
dripRate editableModel =
  DropsPerSecond <| floatString editableModel.decisions.dripText

hours : EditableModel -> Float
hours model =
  let
    h = model.decisions.simulationHoursText |> floatString
    m = model.decisions.simulationMinutesText |> floatString
  in
    h + (m / 60.0)


drainage : EditableModel -> Drainage
drainage model =
  let 
    toEmpty = hoursToEmptyBag model
    planned = hours model
  in
    if planned < toEmpty then
      PartlyEmptied (Hours planned) (Level (endingFractionBagFilled model))
    else
      FullyEmptied (Hours toEmpty)

startingLevel : EditableModel -> Level
startingLevel model =
  Level <| model.background.bagContentsInLiters / model.background.bagCapacityInLiters
        
hoursToEmptyBag : EditableModel -> Float
hoursToEmptyBag model =
  model.background.bagContentsInLiters / (litersPerHour model)
      
endingFractionBagFilled : EditableModel -> Float
endingFractionBagFilled model =
  let
    litersGone = (litersPerHour model) * (hours model)
  in
    (model.background.bagContentsInLiters - litersGone) / model.background.bagCapacityInLiters

litersPerHour : EditableModel -> Float
litersPerHour model =
  let 
    dps = dropsPerSecond model
    milsPerSecond = dps / model.background.dropsPerMil
    milsPerHour = milsPerSecond * 60 * 60
  in
    milsPerHour / 1000

      
dropsPerSecond : EditableModel -> Float
dropsPerSecond model =
  floatString model.decisions.dripText

