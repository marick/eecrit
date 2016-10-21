module IV.Types exposing (..)

import Animation
import Animation.Messenger
import Time exposing (second)
import IV.Msg exposing (Msg)

type alias AnimationState =
  Animation.Messenger.State Msg

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


