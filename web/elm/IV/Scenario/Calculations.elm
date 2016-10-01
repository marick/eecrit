module IV.Scenario.Calculations exposing (..)

import IV.Types exposing (..)
import IV.Scenario.Main exposing (Model)
import IV.Pile.ManagedStrings exposing (floatString)
import Debug

startingFractionBagFilled : Model -> Level
startingFractionBagFilled model =
  Level (model.bagContentsInLiters / model.bagCapacityInLiters)

  
endingFractionBagFilled : Model -> Level
endingFractionBagFilled model =
  let
    (DropsPerSecond dps) = dropsPerSecond model
    (Hours fractionalHours) = hours model
    (Level startingLevel) = startingFractionBagFilled model
    milsPerSecond = Debug.log "mps" (dps / model.dropsPerMil)
    milsPerHour = milsPerSecond * 60 * 60
    litersPerHour = Debug.log "lph" (milsPerHour / 1000)
    decrease = Debug.log "dcrse" (litersPerHour * fractionalHours / model.bagCapacityInLiters)
  in
    Level <| startingLevel - decrease

  
dropsPerSecond : Model -> DropsPerSecond
dropsPerSecond model =
  model.dripText |> floatString |> DropsPerSecond

hours : Model -> Hours
hours model =
  let
    h = model.simulationHoursText |> floatString
    m = model.simulationMinutesText |> floatString
  in
    Hours <| h + (m / 60.0)

