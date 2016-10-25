module IV.Msg exposing (..)

import Animation
import IV.Scenario.Msg as ScenarioMsg
import IV.Scenario.Model as ScenarioModel


type Msg
    = StartSimulation
    | StopSimulation
    | ChoseDripSpeed
    | FluidRanOut
    | ChamberEmptied
    | PickedScenario ScenarioModel.Model

    | AnimationClockTick Animation.Msg

    | ToScenario ScenarioMsg.Msg
