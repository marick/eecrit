module IV.Msg exposing (..)

import Animation
import IV.Scenario.Msg as ScenarioMsg
import IV.Scenario.Models as ScenarioModel
import IV.Types exposing (..)


type Msg
    = StartSimulation
    | StopSimulation
    | ChoseDripRate DropsPerSecond
    | FluidRanOut
    | ChamberEmptied
    | PickedScenario ScenarioModel.EditableModel

    | AnimationClockTick Animation.Msg

    | ToScenario ScenarioMsg.Msg
