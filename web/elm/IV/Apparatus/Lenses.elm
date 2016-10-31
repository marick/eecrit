module IV.Apparatus.Lenses exposing (..)

import Monocle.Lens exposing (..)
import IV.Pile.CmdFlow as CmdFlow


flow = CmdFlow.flow
updateDroplet f = CmdFlow.update apparatus_droplet f 
updateBagLevel f = CmdFlow.update apparatus_bagLevel f 
updateChamberFluid f = CmdFlow.update apparatus_chamberFluid f 
updateHoseFluid f = CmdFlow.update apparatus_hoseFluid f 
updateRate f = CmdFlow.update apparatus_rate f 

apparatus_droplet : Lens { m | droplet : whole } whole
apparatus_droplet =
  let
    get arg1 = arg1.droplet
    set new2 arg1 = { arg1 | droplet = new2 }
  in
    Lens get set

apparatus_bagLevel : Lens { m | bagLevel : whole } whole
apparatus_bagLevel =
  let
    get arg1 = arg1.bagLevel
    set new2 arg1 = { arg1 | bagLevel = new2 }
  in
    Lens get set

apparatus_chamberFluid : Lens { m | chamberFluid : whole } whole
apparatus_chamberFluid =
  let
    get arg1 = arg1.chamberFluid
    set new2 arg1 = { arg1 | chamberFluid = new2 }
  in
    Lens get set

apparatus_hoseFluid : Lens { m | hoseFluid : whole } whole
apparatus_hoseFluid =
  let
    get arg1 = arg1.hoseFluid
    set new2 arg1 = { arg1 | hoseFluid = new2 }
  in
    Lens get set

apparatus_rate : Lens { m | rate : whole } whole
apparatus_rate =
  let
    get arg1 = arg1.rate
    set new2 arg1 = { arg1 | rate = new2 }
  in
    Lens get set

