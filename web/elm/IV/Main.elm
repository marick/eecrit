module IV.Main exposing (..)

import IV.Msg exposing (..)
import Animation
import IV.Scenario.Main as Scenario
import IV.Scenario.Models as ScenarioModel
import IV.Apparatus.Main as Apparatus
import IV.Clock.Main as Clock
import Html.Attributes as Attr

import IV.Types exposing (..)
import IV.Pile.CmdFlow as CmdFlow
import IV.Pile.Animation exposing (AnimationState)
import Animation
import Animation.Messenger

-- Model

type alias Model =
    { scenario : ScenarioModel.EditableModel -- this holds all the user-chosen data

    -- The following hold the animation states of component pieces
    , clock : Clock.Model
    , apparatus : Apparatus.Model
    }

scenario' model val = { model | scenario = val }
clock' model val = { model | clock = val }
apparatus' model val = { model | apparatus = val }

scenarioPart = { getter = .scenario, setter = scenario' }
clockPart = { getter = .clock, setter = clock' }
apparatusPart = { getter = .apparatus, setter = apparatus' }


-- Update

initWithScenario : ScenarioModel.EditableModel -> Model
initWithScenario scenario =
  { scenario = scenario
  , apparatus = Apparatus.unstarted <| ScenarioModel.startingLevel scenario
  , clock = Clock.startingState
  }
  
init : ( Model, Cmd Msg )
init = ( initWithScenario (ScenarioModel.scenario ScenarioModel.cowBackground)
       , Cmd.none
       )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToScenario msg' ->
      Scenario.update msg' |> CmdFlow.change scenarioPart model

    PickedScenario scenario ->
      initWithScenario scenario ! []

    ChoseDripRate dripRate ->
      CmdFlow.chainLike model
        [ (apparatusPart, Apparatus.changeDripRate dripRate)
        , (apparatusPart, Apparatus.showTrueFlow)
        ]

    FluidRanOut ->
      CmdFlow.chainLike model
        [ (apparatusPart, Apparatus.changeDripRate (DropsPerSecond 0))
        , (apparatusPart, Apparatus.showTrueFlow)
        , (apparatusPart, Apparatus.drainChamber)
        ] 

    ChamberEmptied ->
      Apparatus.drainHose |> CmdFlow.change apparatusPart model

    StartSimulation runnableModel ->
      let
        apparatusF = Apparatus.startSimulation runnableModel.drainage
        clockF = Clock.startSimulation runnableModel.totalHours
      in
        model ! []
          |> CmdFlow.augment apparatusPart apparatusF
          |> CmdFlow.augment clockPart clockF
        
    StopSimulation ->
      Apparatus.showTrueFlow |> CmdFlow.change apparatusPart model
        
    AnimationClockTick tick ->
      model ! []
        |> CmdFlow.augment apparatusPart (Apparatus.animationClockTick tick)
        |> CmdFlow.augment clockPart (Clock.animationClockTick tick)
        
-- Subscriptions
    
subscriptions : Model -> Sub Msg
subscriptions model =
  -- Note: This provides a subscription to the animation frame iff
  -- any of the listed animations is running.
  Animation.subscription
    AnimationClockTick
    (Apparatus.animations model.apparatus ++ Clock.animations model.clock)

