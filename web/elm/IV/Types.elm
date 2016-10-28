module IV.Types exposing (..)

import Time exposing (second)

type alias Point = (Float, Float)
type DropsPerSecond = DropsPerSecond Float
type Level = Level Float
type Hours = Hours Float

type Drainage
  = FullyEmptied Hours
  | PartlyEmptied Hours Level
  
asDuration : DropsPerSecond -> Float
asDuration (DropsPerSecond perSecond) = 
  if perSecond == 0.0 then
    10000.0 * second   -- a really slow leak...
  else
    (1 / perSecond) * second


