module IV.Main exposing (..)

import Animation
import IV.Droplet.Main as Droplet
import IV.Scenario.Main as Scenario
import IV.Clock.Main as Clock
import IV.BagLevel.Main as BagLevel

import IV.Types exposing (..)
import IV.Pile.ManagedStrings exposing (floatString)
import IV.Scenario.Calculations as Calc

-- Model

type alias Model =
    { droplet : Droplet.Model
    , scenario : Scenario.Model
    , clock : Clock.Model
    , bagLevel : BagLevel.Model
    }

subscriptions model =
  Animation.subscription
    AnimationClockTick
    (Droplet.animations model.droplet ++ Clock.animations model.clock)


-- Msg

type Msg
    = StartSimulation
    | ChoseDripSpeed
    | AnimationClockTick Animation.Msg
    | PickedScenario Scenario.Model

    | ToScenario Scenario.Msg

-- Update

initWithScenario : Scenario.Model -> Model
initWithScenario scenario =
  { droplet = Droplet.startingState
  , scenario = scenario  
  , clock = Clock.startingState
  , bagLevel = BagLevel.startingState (Calc.startingFractionBagFilled scenario)
  }
  
init : ( Model, Cmd Msg )
init = (initWithScenario Scenario.cowScenario, Cmd.none)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToScenario msg' ->
      ( { model | scenario = Scenario.update msg' model.scenario }
      , Cmd.none
      )

    PickedScenario scenario ->
      ( initWithScenario scenario
      , Cmd.none
      )

    StartSimulation ->
      let
        dps = Calc.dropsPerSecond model.scenario
        hours = Calc.hours model.scenario
        level = Calc.endingFractionBagFilled model.scenario
      in          
      ( { model
          | droplet = Droplet.update (Droplet.StartSimulation Droplet.guaranteedFlow) model.droplet
          , clock = Clock.update (Clock.StartSimulation hours) model.clock
          , bagLevel = BagLevel.update (BagLevel.StartSimulation hours level) model.bagLevel
        }
      , Cmd.none
      )

    ChoseDripSpeed ->
      let
        dps = Calc.dropsPerSecond model.scenario
      in          
      ( { model
          | droplet = Droplet.update (Droplet.StartSimulation dps) model.droplet
        }
      , Cmd.none
      )

    AnimationClockTick tick ->
      ( { model
          | droplet = Droplet.update (Droplet.AnimationClockTick tick) model.droplet
          , clock = Clock.update (Clock.AnimationClockTick tick) model.clock
          , bagLevel = BagLevel.update (BagLevel.AnimationClockTick tick) model.bagLevel
        }
      , Cmd.none
      )
