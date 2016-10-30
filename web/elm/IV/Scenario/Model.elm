module IV.Scenario.Model exposing (..)

import IV.Types exposing (..)

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

