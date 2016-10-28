module IV.Scenario.Calculations exposing ( startingLevel
                                         , drainage
                                         , dropsPerSecond
                                         , hours
                                         )

import IV.Types exposing (..)
import IV.Scenario.Models exposing (EditableModel)
import IV.Pile.ManagedStrings exposing (floatString)

startingLevel : EditableModel -> Level
startingLevel model =
  Level <| model.bagContentsInLiters / model.bagCapacityInLiters
  
dropsPerSecond : EditableModel -> DropsPerSecond
dropsPerSecond model =
  DropsPerSecond <| dropsPerSecond' model

hours : EditableModel -> Hours
hours model =
  Hours <| hours' model

drainage : EditableModel -> Drainage
drainage model =
  let 
    toEmpty = hoursToEmptyBag' model
    planned = hours' model
  in
    if planned < toEmpty then
      PartlyEmptied (Hours planned) (Level (endingFractionBagFilled' model))
    else
      FullyEmptied (Hours toEmpty)

-- Private

dropsPerSecond' : EditableModel -> Float
dropsPerSecond' model =
  floatString model.dripText

startingFractionBagFilled : EditableModel -> Float
startingFractionBagFilled model =
  model.bagContentsInLiters / model.bagCapacityInLiters
  
hours' : EditableModel -> Float
hours' model =
  let
    h = model.simulationHoursText |> floatString
    m = model.simulationMinutesText |> floatString
  in
    h + (m / 60.0)

hoursToEmptyBag' : EditableModel -> Float
hoursToEmptyBag' model =
  model.bagContentsInLiters / (litersPerHour' model)

litersPerHour' : EditableModel -> Float
litersPerHour' model =
  let 
    dps = dropsPerSecond' model
    milsPerSecond = dps / model.dropsPerMil
    milsPerHour = milsPerSecond * 60 * 60
  in
    milsPerHour / 1000

endingFractionBagFilled' : EditableModel -> Float
endingFractionBagFilled' model =
  let
    litersGone = (litersPerHour' model) * (hours' model)
  in
    (model.bagContentsInLiters - litersGone) / model.bagCapacityInLiters
