module IV.Msg exposing (..)

import Animation
import IV.Scenario.Msg as ScenarioMsg
import IV.Scenario.Model as ScenarioModel
import IV.Types exposing (..)
import IV.Scenario.DataExport exposing (RunnableModel)


type Msg
    = StartSimulation RunnableModel
    | StopSimulation
    | ChoseDripRate DropsPerSecond
    | FluidRanOut
    | ChamberEmptied
    | PickedScenario ScenarioModel.EditableModel

    | AnimationClockTick Animation.Msg

    | ToScenario ScenarioMsg.Msg
