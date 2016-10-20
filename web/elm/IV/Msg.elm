module IV.Msg exposing (..)

import Animation
import IV.Scenario.Msg as ScenarioMsg
import IV.Apparatus.Msg as ApparatusMsg
import IV.Scenario.Model as ScenarioModel

type Msg
    = StartSimulation
    | StopSimulation
    | ChoseDripSpeed
    | FluidRanOut
    | PickedScenario ScenarioModel.Model

    | AnimationClockTick Animation.Msg

    | ToScenario ScenarioMsg.Msg
    | ToApparatus ApparatusMsg.Msg

