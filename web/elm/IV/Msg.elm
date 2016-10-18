module IV.Msg exposing (..)

import Animation
import IV.Scenario.Msg as ScenarioMsg
import IV.Scenario.Main as Scenario

type Msg
    = StartSimulation
    | ChoseDripSpeed
    | PickedScenario Scenario.Model

    | AnimationClockTick Animation.Msg

    | ToScenario ScenarioMsg.Msg

