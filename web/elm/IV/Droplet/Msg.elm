module IV.Droplet.Msg exposing (..)

import Animation
import IV.Types exposing (..)

type Msg
  = ChangeDripRate DropsPerSecond
  | AnimationClockTick Animation.Msg

