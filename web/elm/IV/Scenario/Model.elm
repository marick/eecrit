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
  , bagCapacityInLiters : String
  , bagContentsInLiters : String
  , bagType : String
  , dropsPerMil : String
  , animalDescription : String
  }

-- Treatment Decisions   

type alias TreatmentDecisions =
  {
    dripRate : String
  , simulationHours : String
  , simulationMinutes : String
  }

defaultDecisions =
  { dripRate = "0"
  , simulationHours = "0"
  , simulationMinutes = "0"
  }

-- Specific starting Scenarios

editableBackground =
  { tag = "Write your own"
  , bagCapacityInLiters = "0"
  , bagContentsInLiters = "0"
  , bagType = "container"
  , dropsPerMil = "15.0"
  , animalDescription = "a case"
  }

cowBackground : CaseBackground
cowBackground = 
  { editableBackground
    | tag = "1560 lb. cow"
    , animalDescription = "a 1560 lb 3d lactation purebred Holstein"
    , bagCapacityInLiters = "20"
    , bagContentsInLiters = "19"
    , bagType = "5-gallon carboy"
  }

calfBackground : CaseBackground
calfBackground = 
  { editableBackground
    | tag = "90 lb. heifer calf"
    , animalDescription = "a 90 lb. 10-day-old Hereford heifer calf"
    , bagCapacityInLiters = "2"
    , bagContentsInLiters = "2"
    , bagType = "bag"
  }

