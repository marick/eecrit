module IV.Lenses exposing (..)

import Monocle.Lens exposing (..)
import IV.Pile.CmdFlow as CmdFlow


flow = CmdFlow.flow
updateScenario pairProducingF = CmdFlow.update model_scenario pairProducingF
updateApparatus pairProducingF = CmdFlow.update model_apparatus pairProducingF
updateClock pairProducingF = CmdFlow.update model_clock pairProducingF 

setPage newVal = CmdFlow.set model_page newVal

model_page : Lens { m | page : whole } whole
model_page =
  let
    get arg1 = arg1.page
    set new2 arg1 = { arg1 | page = new2 }
  in
    Lens get set

model_scenario : Lens { m | scenario : whole } whole
model_scenario =
  let
    get arg1 = arg1.scenario
    set new2 arg1 = { arg1 | scenario = new2 }
  in
    Lens get set

model_clock : Lens { m | clock : whole } whole
model_clock =
  let
    get arg1 = arg1.clock
    set new2 arg1 = { arg1 | clock = new2 }
  in
    Lens get set

model_apparatus : Lens { m | apparatus : whole } whole
model_apparatus =
  let
    get arg1 = arg1.apparatus
    set new2 arg1 = { arg1 | apparatus = new2 }
  in
    Lens get set

