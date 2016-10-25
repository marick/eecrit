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

import IV.Apparatus.Droplet as Droplet
import IV.Apparatus.BagView as BagView
import IV.Apparatus.ChamberView as ChamberView
import IV.Apparatus.HoseView as HoseView
import IV.Types exposing (..)
import IV.Scenario.Calculations as Calc
import IV.Scenario.Model as Scenario
import IV.Msg exposing (Msg)
import IV.Pile.CmdFlow as CmdFlow
import List

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

droplet' model val = { model | droplet = val }
bagLevel' model val = { model | bagLevel = (Debug.log "set bag level" val) }
chamberFluid' model val = { model | chamberFluid = (Debug.log "set chamber fluid" val) }
hoseFluid' model val = { model | hoseFluid = (Debug.log "set chamber fluid" val) }
rate' model val = { model | rate = val }

dropletPart = { getter = .droplet, setter = droplet' }
bagLevelPart = { getter = .bagLevel, setter = bagLevel' }
chamberFluidPart = { getter = .chamberFluid, setter = chamberFluid' }
hoseFluidPart = { getter = .hoseFluid, setter = hoseFluid' }
ratePart = { getter = .rate, setter = rate' }

unstarted scenario =
  { droplet = Droplet.noDrips
  , bagLevel = BagView.startingState (Calc.startingLevel scenario)
  , chamberFluid = ChamberView.startingState
  , hoseFluid = HoseView.startingState
  , rate = DropsPerSecond 0
  }

-- Updates

showTrueFlow : Model -> ( Model, Cmd Msg)
showTrueFlow model =
  Droplet.showTrueFlow model.rate |> CmdFlow.change dropletPart model

changeDripRate : DropsPerSecond -> Model -> ( Model, Cmd Msg )
changeDripRate dropsPerSecond model =
  rate' model dropsPerSecond ! []

drainChamber : Model -> ( Model, Cmd Msg )
drainChamber model =
  ChamberView.startDraining |> CmdFlow.change chamberFluidPart model

drainHose : Model -> (Model, Cmd Msg)
drainHose model = 
  HoseView.startDraining |> CmdFlow.change hoseFluidPart model

startSimulation : Scenario.Model -> Model -> ( Model, Cmd Msg)
startSimulation scenario model =
  CmdFlow.chainLike model
    [ (dropletPart, Droplet.showTimeLapseFlow)
    , (bagLevelPart, BagView.startDraining <| Calc.drainage scenario)
    ]
    
animationClockTick tick model =
  CmdFlow.chainLike model
    [ (dropletPart, Droplet.animationClockTick tick)
    , (bagLevelPart, BagView.animationClockTick tick)
    , (chamberFluidPart, ChamberView.animationClockTick tick)
    , (hoseFluidPart, HoseView.animationClockTick tick)
    ]
