module IV.Main exposing (..)

import IV.Msg exposing (..)
import Animation
import IV.Scenario.Main as Scenario
import IV.Scenario.Model as ScenarioModel
import IV.Apparatus.Main as Apparatus
import IV.Clock.Main as Clock

import IV.Types exposing (..)
import IV.Scenario.Calculations as Calc
import IV.Pile.CmdFlow as CmdFlow

-- Model

type alias Model =
    { scenario : ScenarioModel.Model -- this holds all the user-chosen data

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

initWithScenario : ScenarioModel.Model -> Model
initWithScenario scenario =
  { scenario = scenario
  , apparatus = Apparatus.unstarted scenario
  , clock = Clock.startingState
  }
  
init : ( Model, Cmd Msg )
init = (initWithScenario Scenario.cowScenario, Cmd.none)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToScenario msg' ->
      Scenario.update msg' |> CmdFlow.change scenarioPart model

    PickedScenario scenario ->
      initWithScenario scenario ! []

    ChoseDripSpeed ->
      CmdFlow.chainLike model
        [ (apparatusPart, Apparatus.changeDripRate (Calc.dropsPerSecond model.scenario))
        , (apparatusPart, Apparatus.showTrueFlow)
        ]

    FluidRanOut ->
      CmdFlow.chainLike model
        [ (apparatusPart, Apparatus.changeDripRate (DropsPerSecond 0))
        , (apparatusPart, Apparatus.showTrueFlow)
        , (apparatusPart, Apparatus.drainChamber)
        ] 

    StartSimulation ->
      let
        apparatusF = Apparatus.startSimulation model.scenario
        clockF = Clock.startSimulation <| Calc.hours model.scenario
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

