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
    | ToScenario Scenario.Msg
    | AnimationClockTick Animation.Msg

-- Update
  
init : ( Model, Cmd Msg )
init =
  let
    scenario = Scenario.startingState
  in
  ( { droplet = Droplet.startingState
    , scenario = scenario  
    , clock = Clock.startingState
    , bagLevel = BagLevel.startingState (Calc.startingFractionBagFilled scenario)
    }
  , Cmd.none
  )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToScenario msg' ->
      ( { model | scenario = Scenario.update msg' model.scenario }
      , Cmd.none
      )

    StartSimulation ->
      let
        dps = Calc.dropsPerSecond model.scenario
        f = Calc.fractionalHours model.scenario
        level = Calc.endingFractionBagFilled model.scenario
      in          
      ( { model
          | droplet = Droplet.update (Droplet.StartSimulation dps) model.droplet
          , clock = Clock.update (Clock.StartSimulation f) model.clock
          , bagLevel = BagLevel.update (BagLevel.StartSimulation f level) model.bagLevel
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
