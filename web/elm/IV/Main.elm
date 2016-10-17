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
    { scenario : Scenario.Model -- this holds all the user-chosen data

    -- The following hold the animation states of component pieces
    , droplet : Droplet.Model
    , clock : Clock.Model
    , bagLevel : BagLevel.Model
    }

subscriptions : Model -> Sub Msg
subscriptions model =
  -- Note: This provides a subscription to the animation frame iff
  -- any of the listed animations is running.
  Animation.subscription
    AnimationClockTick
    (Droplet.animations model.droplet ++
       Clock.animations model.clock  ++
       BagLevel.animations model.bagLevel)


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
  { droplet = Droplet.noDrips
  , scenario = scenario  
  , clock = Clock.startingState
  , bagLevel = BagLevel.startingState (Calc.startingFractionBagFilled scenario)
  }
  
init : ( Model, Cmd Msg )
init = (initWithScenario Scenario.cowScenario, Cmd.none)

allAnimationUpdate : Model -> (Droplet.Msg, Clock.Msg, BagLevel.Msg) -> Model
allAnimationUpdate model (dropletMsg, clockMsg, bagLevelMsg) = 
  { model
    | droplet = Droplet.update dropletMsg model.droplet
    , clock = Clock.update clockMsg model.clock
    , bagLevel = BagLevel.update bagLevelMsg model.bagLevel
  }

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

    ChoseDripSpeed ->
      let
        dps = Calc.dropsPerSecond model.scenario
      in          
      ( { model
          | droplet = Droplet.update (Droplet.ShowTrueFlow dps) model.droplet
        }
      , Cmd.none
      )

    StartSimulation ->
      let
        dps = Calc.dropsPerSecond model.scenario
        hours = Calc.hours model.scenario
        level = Calc.endingFractionBagFilled model.scenario
      in          
      ( allAnimationUpdate model
          ( Droplet.ShowTimeLapseFlow
          , Clock.StartSimulation hours
          , BagLevel.StartSimulation hours level
          )
      , Cmd.none
      )

    AnimationClockTick tick ->
      ( allAnimationUpdate model
          ( Droplet.AnimationClockTick tick
          , Clock.AnimationClockTick tick
          , BagLevel.AnimationClockTick tick
          )
      , Cmd.none
      )
