module IV.Clock.Msg exposing (..)

import Animation
import IV.Clock.Model exposing (Model)
import IV.Types exposing (..)

type Msg
  = AdvanceHours Int
  | AnimationClockTick Animation.Msg
