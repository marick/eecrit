module IV.Lenses exposing (..)

import Monocle.Lens exposing (..)
import IV.Pile.CmdFlow as CmdFlow


flow = CmdFlow.flow
updateScenario f = CmdFlow.update model_scenario f 
updateApparatus f = CmdFlow.update model_apparatus f 
updateClock f = CmdFlow.update model_clock f 
  

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

