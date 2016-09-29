module IV.Msg exposing (..)

import Animation
import IV.Scenario.Msg as Scenario

type Msg
    = StartSimulation
    | ToScenario Scenario.Msg
    | AnimationClockTick Animation.Msg

