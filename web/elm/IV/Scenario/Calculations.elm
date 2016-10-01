module IV.Scenario.Calculations exposing (..)

import IV.Types exposing (..)
import IV.Scenario.Main exposing (Model)
import IV.Pile.ManagedStrings exposing (floatString)

startingFractionBagFilled : Model -> Level
startingFractionBagFilled model =
  Level (model.bagContentsInLiters / model.bagCapacityInLiters)

  
endingFractionBagFilled : Model -> Level
endingFractionBagFilled model =
  Level 0.1

  
dropsPerSecond : Model -> DropsPerSecond
dropsPerSecond model =
  model.dripText |> floatString |> DropsPerSecond


fractionalHours model =
  let
    hours = model.simulationHoursText |> floatString
    minutes = model.simulationMinutesText |> floatString
  in
    hours + (minutes / 60.0)

