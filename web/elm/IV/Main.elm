module IV.Main exposing (..)

import IV.Msg exposing (..)
import Animation
import IV.Apparatus.Droplet as Droplet
import IV.Scenario.Main as Scenario
import IV.Scenario.Model as ScenarioModel
import IV.Apparatus.Main as Apparatus
import IV.Clock.Main as Clock
import IV.Apparatus.BagLevel as BagLevel

import IV.Types exposing (..)
import IV.Scenario.Calculations as Calc

-- Model

type alias Model =
    { scenario : ScenarioModel.Model -- this holds all the user-chosen data
    , simulation : Apparatus.Model

    -- The following hold the animation states of component pieces
    , droplet : Droplet.Model
    , clock : Clock.Model
    , bagLevel : BagLevel.Model
    }

scenario' model val =
  { model | scenario = val }
droplet' model val =
  { model | droplet = val }

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

initWithScenario : ScenarioModel.Model -> Model
initWithScenario scenario =
  { droplet = Droplet.noDrips
  , scenario = scenario
  , simulation = Apparatus.unstarted
  , clock = Clock.startingState
  , bagLevel = BagLevel.startingState (Calc.startingFractionBagFilled scenario)
  }
  
init : ( Model, Cmd Msg )
init = (initWithScenario Scenario.cowScenario, Cmd.none)


updateScenario model updater =
  let
    ( newScenario, cmd ) = updater model.scenario
  in
    ( scenario' model newScenario, cmd)
  
updateDroplet model updater =
  let
    (newDroplet, cmd ) = updater model.droplet
  in
    ( droplet' model newDroplet, cmd)

updateAllAnimations model (dropletUpdater, clockUpdater, bagLevelUpdater) =
  let
    (newDroplet, dropletCmd) = dropletUpdater model.droplet
    (newClock, clockCmd) = clockUpdater model.clock
    (newBagLevel, bagLevelCmd) = bagLevelUpdater model.bagLevel

    newModel = { model
                 | droplet = newDroplet
                 , clock = newClock
                 , bagLevel = newBagLevel }
    cmd = Cmd.batch [dropletCmd, clockCmd, bagLevelCmd]
  in
    (newModel, cmd)


showTrueFlow model =
  let
    dps = Calc.dropsPerSecond model.scenario
  in
    Droplet.showTrueFlow dps |> updateDroplet model
  

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToScenario msg' ->
      Scenario.update msg' |> updateScenario model

    ToApparatus msg' -> 
      ( model
      , Cmd.none
      )

    PickedScenario scenario ->
      ( initWithScenario scenario
      , Cmd.none
      )

    ChoseDripSpeed ->
      showTrueFlow model

    StartSimulation ->
      let
        hours = Calc.hours model.scenario
        level = Calc.endingFractionBagFilled model.scenario
      in
        updateAllAnimations model 
          ( Droplet.showTimeLapseFlow
          , Clock.startSimulation hours
          , BagLevel.startSimulation hours level
          )

    StopSimulation ->
      showTrueFlow model
        
    AnimationClockTick tick ->
      updateAllAnimations model
        ( Droplet.animationClockTick tick
        , Clock.animationClockTick tick
        , BagLevel.animationClockTick tick
        )
        
