module IV.Msg exposing (..)

import Animation
import IV.Scenario.Msg as Scenario

type Msg
    = ChangeDripRate
    | AdvanceHours
    | ToScenario Scenario.Msg
    | AnimationClockTick Animation.Msg

