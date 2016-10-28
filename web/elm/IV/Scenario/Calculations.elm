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
  Level <| model.background.bagContentsInLiters / model.background.bagCapacityInLiters
  
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
  floatString model.decisions.dripText

startingFractionBagFilled : EditableModel -> Float
startingFractionBagFilled model =
  model.background.bagContentsInLiters / model.background.bagCapacityInLiters
  
hours' : EditableModel -> Float
hours' model =
  let
    h = model.decisions.simulationHoursText |> floatString
    m = model.decisions.simulationMinutesText |> floatString
  in
    h + (m / 60.0)

hoursToEmptyBag' : EditableModel -> Float
hoursToEmptyBag' model =
  model.background.bagContentsInLiters / (litersPerHour' model)

litersPerHour' : EditableModel -> Float
litersPerHour' model =
  let 
    dps = dropsPerSecond' model
    milsPerSecond = dps / model.background.dropsPerMil
    milsPerHour = milsPerSecond * 60 * 60
  in
    milsPerHour / 1000

endingFractionBagFilled' : EditableModel -> Float
endingFractionBagFilled' model =
  let
    litersGone = (litersPerHour' model) * (hours' model)
  in
    (model.background.bagContentsInLiters - litersGone) / model.background.bagCapacityInLiters
