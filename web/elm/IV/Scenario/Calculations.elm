module IV.Scenario.Calculations exposing ( startingLevel
                                         , drainage
                                         , dropsPerSecond
                                         , hours
                                         )

import IV.Types exposing (..)
import IV.Scenario.Model exposing (Model)
import IV.Pile.ManagedStrings exposing (floatString)

startingLevel : Model -> Level
startingLevel model =
  Level <| model.bagContentsInLiters / model.bagCapacityInLiters
  
dropsPerSecond : Model -> DropsPerSecond
dropsPerSecond model =
  DropsPerSecond <| dropsPerSecond' model

hours : Model -> Hours
hours model =
  Hours <| hours' model

drainage : Model -> Drainage
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

dropsPerSecond' : Model -> Float
dropsPerSecond' model =
  floatString model.dripText

startingFractionBagFilled : Model -> Float
startingFractionBagFilled model =
  model.bagContentsInLiters / model.bagCapacityInLiters
  
hours' : Model -> Float
hours' model =
  let
    h = model.simulationHoursText |> floatString
    m = model.simulationMinutesText |> floatString
  in
    h + (m / 60.0)

hoursToEmptyBag' : Model -> Float
hoursToEmptyBag' model =
  model.bagContentsInLiters / (litersPerHour' model)

litersPerHour' : Model -> Float
litersPerHour' model =
  let 
    dps = dropsPerSecond' model
    milsPerSecond = dps / model.dropsPerMil
    milsPerHour = milsPerSecond * 60 * 60
  in
    milsPerHour / 1000

endingFractionBagFilled' : Model -> Float
endingFractionBagFilled' model =
  let
    litersGone = (litersPerHour' model) * (hours' model)
  in
    (model.bagContentsInLiters - litersGone) / model.bagCapacityInLiters
