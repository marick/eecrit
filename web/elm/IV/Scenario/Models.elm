module IV.Scenario.Models exposing (..)

import IV.Types exposing (..)
import IV.Pile.ManagedStrings exposing (floatString)

type alias EditableModel =
  { background : CaseBackground
  , caseBackgroundEditorOpen : Bool
  , decisions : TreatmentDecisions
  }

  
scenario : CaseBackground -> EditableModel
scenario background =
  { background = background
  , caseBackgroundEditorOpen = False
  , decisions = defaultDecisions
  }

  

  
type alias CaseBackground =
  { tag : String
  , bagCapacityInLiters : Float
  , bagContentsInLiters : Float
  , bagType : String
  , dropsPerMil : Float
  , animalDescription : String
  , weightInPounds : Int
  }

defaultBackground =
  { tag = "Case shorthand (optional)"
  , bagCapacityInLiters = 0
  , bagContentsInLiters = 0
  , bagType = "kind of bag (optional)"
  , dropsPerMil = 15.0
  , animalDescription = "Animal weight in pounds (optional)"
  , weightInPounds = 0
  }


-- Treatment Decisions   

type alias TreatmentDecisions =
  {
    dripText : String
  , simulationHoursText : String
  , simulationMinutesText : String
  }

defaultDecisions =
  { dripText = "0"
  , simulationHoursText = "0"
  , simulationMinutesText = "0"
  }

-- Specific starting Scenarios

cowBackground : CaseBackground
cowBackground = 
  { defaultBackground
    | tag = "1560 lb. cow"
    , animalDescription = "3d lactation purebred Holstein"
    , weightInPounds = 1560
    , bagCapacityInLiters = 20
    , bagContentsInLiters = 19
    , bagType = "5-gallon carboy"
  }

calfBackground : CaseBackground
calfBackground = 
  { defaultBackground
    | tag = "90 lb. heifer calf"
    , animalDescription = "10-day-old Hereford heifer calf"
    , weightInPounds = 90
    , bagCapacityInLiters = 2
    , bagContentsInLiters = 2
    , bagType = "2-liter bag"
  }

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

