module IV.Msg exposing (..)

import Animation
import IV.Scenario.Msg as ScenarioMsg
import IV.Scenario.Model as ScenarioModel
import IV.Types exposing (..)
import IV.Scenario.DataExport exposing (SimulationData)
import Navigation

type Msg
    = StartSimulation SimulationData
    | StopSimulation
    | ChoseDripRate DropsPerSecond
    | FluidRanOut
    | ChamberEmptied
    | PickedScenario ScenarioModel.EditableModel
    | RestartScenario

    | AnimationClockTick Animation.Msg

    | ToScenario ScenarioMsg.Msg

    | OpenCaseBackgroundEditor
    | CloseCaseBackgroundEditor

    | NoticePageChange Navigation.Location
    | StartPageChange PageChoice
      
