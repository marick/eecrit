module IV.Apparatus.Main exposing
  ( Model
  , animations
  , unstarted
  , showTrueFlow
  , startSimulation
  , animationClockTick
  , changeDripRate
  , drainChamber
  , drainHose
  )

import IV.Apparatus.BagView as BagView
import IV.Apparatus.ChamberView as ChamberView
import IV.Apparatus.Droplet as Droplet
import IV.Apparatus.HoseView as HoseView
import IV.Apparatus.Lenses exposing (..)
import IV.Types exposing (..)
import IV.Msg exposing (Msg)
import IV.Pile.Animation exposing (AnimationState)

animations model = 
  [model.droplet, model.bagLevel, model.chamberFluid, model.hoseFluid]

-- Model
    
type alias Model =
  { droplet : AnimationState
  , bagLevel : AnimationState
  , chamberFluid : AnimationState
  , hoseFluid : AnimationState
  , rate : DropsPerSecond
  }

unstarted startingLevel =
  { droplet = Droplet.noDrips
  , bagLevel = BagView.startingState startingLevel
  , chamberFluid = ChamberView.startingState
  , hoseFluid = HoseView.startingState
  , rate = DropsPerSecond 0
  }

-- Updates

showTrueFlow : Model -> ( Model, Cmd Msg)
showTrueFlow model =
  flow model
    |> updateDroplet (Droplet.showTrueFlow model.rate)

changeDripRate : DropsPerSecond -> Model -> ( Model, Cmd Msg )
changeDripRate dropsPerSecond model =
  ( apparatus_rate.set dropsPerSecond model
  , Cmd.none
  )

drainChamber : Model -> ( Model, Cmd Msg )
drainChamber model =
  flow model
    |> updateChamberFluid ChamberView.startDraining

drainHose : Model -> (Model, Cmd Msg)
drainHose model =
  flow model
    |> updateHoseFluid HoseView.startDraining

startSimulation : Drainage -> Model -> ( Model, Cmd Msg)
startSimulation drainage model =
  flow model
    |> updateDroplet Droplet.showTimeLapseFlow
    |> updateBagLevel (BagView.startDraining drainage)
    
animationClockTick tick model =
  flow model
    |> updateDroplet (Droplet.animationClockTick tick)
    |> updateBagLevel (BagView.animationClockTick tick)
    |> updateChamberFluid (ChamberView.animationClockTick tick)
    |> updateHoseFluid (HoseView.animationClockTick tick)
