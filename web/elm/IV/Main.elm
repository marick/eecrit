module IV.Main exposing (..)

import IV.Msg exposing (..)
import Animation
import IV.Apparatus.Droplet as Droplet
import IV.Scenario.Main as Scenario
import IV.Apparatus.Main as Apparatus
import IV.Clock.Main as Clock
import IV.Apparatus.BagLevel as BagLevel

import IV.Types exposing (..)
import IV.Scenario.Calculations as Calc

-- Model

type alias Model =
    { scenario : Scenario.Model -- this holds all the user-chosen data
    , simulation : Apparatus.Model

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


-- Update

initWithScenario : Scenario.Model -> Model
initWithScenario scenario =
  { droplet = Droplet.noDrips
  , scenario = scenario
  , simulation = Apparatus.unstarted
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

    ToApparatus msg' ->
      ( model
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
          | droplet = Droplet.showTrueFlow model.droplet dps
        }
      , Cmd.none
      )

    StartSimulation ->
      let
        dps = Calc.dropsPerSecond model.scenario
        hours = Calc.hours model.scenario
        level = Calc.endingFractionBagFilled model.scenario
      in          
      (
       { model
         | droplet = Droplet.showTimeLapseFlow model.droplet
         , clock = Clock.startSimulation model.clock hours
         , bagLevel = BagLevel.startSimulation model.bagLevel hours level
       }
      , Cmd.none
      )

    AnimationClockTick tick ->
      ( 
       { model
         | droplet = Droplet.animationClockTick model.droplet tick
         , clock = Clock.animationClockTick model.clock tick
         , bagLevel = BagLevel.animationClockTick model.bagLevel tick
       }
      , Cmd.none
      )
        
