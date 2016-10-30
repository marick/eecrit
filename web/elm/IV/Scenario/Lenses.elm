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

decisions_dripText : Lens TreatmentDecisions String
decisions_dripText =
  let
    get arg1 = arg1.dripText
    set new2 arg1 = { arg1 | dripText = new2 }
  in
    Lens get set

decisions_simulationHoursText : Lens TreatmentDecisions String
decisions_simulationHoursText =
  let
    get arg1 = arg1.simulationHoursText
    set new2 arg1 = { arg1 | simulationHoursText = new2 }
  in
    Lens get set

decisions_simulationMinutesText : Lens TreatmentDecisions String
decisions_simulationMinutesText =
  let
    get arg1 = arg1.simulationMinutesText
    set new2 arg1 = { arg1 | simulationMinutesText = new2 }
  in
    Lens get set


-- Model down to Decisions

model_dripText = Monocle.Lens.compose model_decisions decisions_dripText
model_simulationHoursText = Monocle.Lens.compose model_decisions decisions_simulationHoursText
model_simulationMinutesText = Monocle.Lens.compose model_decisions decisions_simulationMinutesText
