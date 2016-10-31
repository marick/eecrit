module IV.Clock.Lenses exposing (..)

import Monocle.Lens exposing (..)
import IV.Pile.CmdFlow as CmdFlow


flow = CmdFlow.flow
updateHourHand f = CmdFlow.update clock_hourHand f 
updateMinuteHand f = CmdFlow.update clock_minuteHand f 

clock_hourHand : Lens { m | hourHand : whole } whole
clock_hourHand =
  let
    get arg1 = arg1.hourHand
    set new2 arg1 = { arg1 | hourHand = new2 }
  in
    Lens get set

clock_minuteHand : Lens { m | minuteHand : whole } whole
clock_minuteHand =
  let
    get arg1 = arg1.minuteHand
    set new2 arg1 = { arg1 | minuteHand = new2 }
  in
    Lens get set

