module IV.Main exposing (..)

import Animation
import Animation.Messenger
import Html.Attributes as Attr

import IV.Lenses exposing (..)
import IV.Msg exposing (..)
import IV.Types exposing (..)

import IV.Apparatus.Main as Apparatus
import IV.Clock.Main as Clock
import IV.Scenario.Main as Scenario
import IV.Scenario.Model as ScenarioModel
import IV.Scenario.DataExport as DataExport


-- Model

type alias Model =
    { scenario : ScenarioModel.EditableModel -- this holds all the user-chosen data

    -- The following hold the animation states of component pieces
    , clock : Clock.Model
    , apparatus : Apparatus.Model
    }

-- Update

initWithScenario : ScenarioModel.EditableModel -> (Model, Cmd Msg)
initWithScenario scenario =
  ( { scenario = scenario
    , apparatus = Apparatus.unstarted <| DataExport.startingLevel scenario
    , clock = Clock.startingState
    }
  , Cmd.none
  )
  
init : ( Model, Cmd Msg )
init = initWithScenario (ScenarioModel.scenario ScenarioModel.cowBackground)


changeDripRate dripRate = updateApparatus (Apparatus.changeDripRate dripRate)
showTrueFlow = updateApparatus Apparatus.showTrueFlow
drainChamber = updateApparatus Apparatus.drainChamber
drainHose = updateApparatus Apparatus.drainHose

startApparatusSimulation drainage = updateApparatus (Apparatus.startSimulation drainage)
startClock hours = updateClock (Clock.startSimulation hours)

openCaseBackgroundEditor = updateScenario Scenario.openCaseBackgroundEditor
closeCaseBackgroundEditor = updateScenario Scenario.closeCaseBackgroundEditor

animateClock tick = updateClock (Clock.animationClockTick tick)
animateApparatus tick = updateApparatus (Apparatus.animationClockTick tick)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToScenario msg' ->
      flow model
        |> updateScenario (Scenario.update msg')

    PickedScenario scenario ->
      initWithScenario scenario

    ChoseDripRate dripRate ->
      flow model
        |> changeDripRate dripRate
        |> showTrueFlow

    FluidRanOut ->
      flow model
        |> changeDripRate (DropsPerSecond 0)
        |> showTrueFlow
        |> drainChamber

    ChamberEmptied ->   -- TODO: This should just be part of Apparatus.drainChamber
      flow model
        |> drainHose

    StartSimulation runnableModel ->
      flow model
        |> startApparatusSimulation runnableModel.drainage
        |> startClock runnableModel.totalHours
        
    StopSimulation ->
      flow model
        |> showTrueFlow

    OpenCaseBackgroundEditor ->
      flow model
        |> openCaseBackgroundEditor
        |> showTrueFlow
        
    CloseCaseBackgroundEditor ->
      initWithScenario model.scenario
        |> closeCaseBackgroundEditor
        
    AnimationClockTick tick ->
      flow model
        |> animateClock tick
        |> animateApparatus tick
        
-- Subscriptions
    
subscriptions : Model -> Sub Msg
subscriptions model =
  -- Note: This provides a subscription to the animation frame iff
  -- any of the listed animations is running.
  Animation.subscription
    AnimationClockTick
    (Apparatus.animations model.apparatus ++ Clock.animations model.clock)

