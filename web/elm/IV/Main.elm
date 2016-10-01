module IV.Main exposing (..)

import Animation
import IV.Droplet.Main as Droplet
import IV.Scenario.Main as Scenario
import IV.Clock.Model as Clock
import IV.Clock.Update as ClockUpdate
import IV.BagLevel.Main as BagLevel

import IV.Types exposing (..)
import IV.Clock.Msg as ClockMsg
import IV.Pile.ManagedStrings exposing (floatString)

-- Model

type alias Model =
    { droplet : Droplet.Model
    , scenario : Scenario.Model
    , clock : Clock.Model
    , bagLevel : BagLevel.Model
    }

init : ( Model, Cmd Msg )
init =
  let
    scenario = Scenario.startingState
  in
  ( { droplet = Droplet.startingState
    , scenario = scenario  
    , clock = Clock.startingState
    , bagLevel = BagLevel.startingState (fractionBagFilled scenario)
    }
  , Cmd.none
  )

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
  
fractionBagFilled scenario =
  (scenario.bagContentsInLiters / scenario.bagCapacityInLiters)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToScenario msg' ->
      ( { model | scenario = Scenario.update msg' model.scenario }
      , Cmd.none
      )

    StartSimulation ->
      let
        dropletData = model.scenario.dripText |> floatString |> DropsPerSecond
        hours = model.scenario.simulationHoursText |> floatString
        minutes = model.scenario.simulationMinutesText |> floatString
        f = fractionalHours hours minutes
      in          
      ( { model
          | droplet = Droplet.update (Droplet.StartSimulation dropletData) model.droplet
          , clock = ClockUpdate.update (ClockMsg.StartSimulation f) model.clock
          , bagLevel = BagLevel.update (BagLevel.StartSimulation f dropletData) model.bagLevel
        }
      , Cmd.none
      )

    AnimationClockTick tick ->
      ( { model
          | droplet = Droplet.update (Droplet.AnimationClockTick tick) model.droplet
          , clock = ClockUpdate.update (ClockMsg.AnimationClockTick tick) model.clock
          , bagLevel = BagLevel.update (BagLevel.AnimationClockTick tick) model.bagLevel
        }
      , Cmd.none
      )
      
