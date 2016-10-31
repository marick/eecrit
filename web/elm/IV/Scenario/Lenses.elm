module IV.Scenario.Lenses exposing (..)

import Monocle.Lens exposing (..)
import IV.Scenario.Model exposing (..)

-- Model fields

model_decisions : Lens EditableModel TreatmentDecisions
model_decisions =
  let
    get arg1 = arg1.decisions
    set new2 arg1 = { arg1 | decisions = new2 }
  in
    Lens get set

model_background : Lens EditableModel CaseBackground
model_background =
  let
    get arg1 = arg1.background
    set new2 arg1 = { arg1 | background = new2 }
  in
    Lens get set

model_caseBackgroundEditorOpen : Lens EditableModel Bool
model_caseBackgroundEditorOpen =
  let
    get arg1 = arg1.caseBackgroundEditorOpen
    set new2 arg1 = { arg1 | caseBackgroundEditorOpen = new2 }
  in
    Lens get set

--

-- Decisions 

decisions_dripRate : Lens TreatmentDecisions String
decisions_dripRate =
  let
    get arg1 = arg1.dripRate
    set new2 arg1 = { arg1 | dripRate = new2 }
  in
    Lens get set

decisions_simulationHours : Lens TreatmentDecisions String
decisions_simulationHours =
  let
    get arg1 = arg1.simulationHours
    set new2 arg1 = { arg1 | simulationHours = new2 }
  in
    Lens get set

decisions_simulationMinutes : Lens TreatmentDecisions String
decisions_simulationMinutes =
  let
    get arg1 = arg1.simulationMinutes
    set new2 arg1 = { arg1 | simulationMinutes = new2 }
  in
    Lens get set


-- Model down to Decisions

model_dripRate = Monocle.Lens.compose model_decisions decisions_dripRate
model_simulationHours = Monocle.Lens.compose model_decisions decisions_simulationHours
model_simulationMinutes = Monocle.Lens.compose model_decisions decisions_simulationMinutes
