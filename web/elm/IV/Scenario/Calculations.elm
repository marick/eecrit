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

hours : Model -> Hours
hours model =
  let
    h = model.simulationHoursText |> floatString
    m = model.simulationMinutesText |> floatString
  in
    Hours <| h + (m / 60.0)

