module IV.Msg exposing (..)

import Animation
import IV.Scenario.Msg as ScenarioMsg
import IV.Scenario.Models as ScenarioModel


type Msg
    = StartSimulation
    | StopSimulation
    | ChoseDripSpeed
    | FluidRanOut
    | ChamberEmptied
    | PickedScenario ScenarioModel.EditableModel

    | AnimationClockTick Animation.Msg

    | ToScenario ScenarioMsg.Msg
