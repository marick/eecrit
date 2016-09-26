module IV.Msg exposing (..)

import Animation
import IV.SpeedControl.Msg as SpeedControl

type Msg
    = ChangeDripRate
    | AdvanceHours
    | ToSpeedControl SpeedControl.Msg
    | AnimationClockTick Animation.Msg

