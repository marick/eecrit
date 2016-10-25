module IV.Apparatus.Main exposing
  ( Model
  , animations
  , unstarted
  , showTrueFlow
  , startSimulation
  , animationClockTick
  , changeDripRate
  , drainChamber
  )

import IV.Apparatus.Droplet as Droplet
import IV.Apparatus.BagView as BagView
import IV.Apparatus.ChamberView as ChamberView
import IV.Types exposing (..)
import IV.Scenario.Calculations as Calc
import IV.Scenario.Model as Scenario
import IV.Msg exposing (Msg)
import IV.Pile.CmdFlow as CmdFlow
import List

animations model = 
  [model.droplet, model.bagLevel, model.chamberFluid]

-- Model
    
type alias Model =
  { droplet : AnimationState
  , bagLevel : AnimationState
  , chamberFluid : AnimationState
  , rate : DropsPerSecond
  }

droplet' model val = { model | droplet = val }
bagLevel' model val = { model | bagLevel = (Debug.log "set bag level" val) }
chamberFluid' model val = { model | chamberFluid = (Debug.log "set chamber fluid" val) }
rate' model val = { model | rate = val }

dropletPart = { getter = .droplet, setter = droplet' }
bagLevelPart = { getter = .bagLevel, setter = bagLevel' }
chamberFluidPart = { getter = .chamberFluid, setter = chamberFluid' }
ratePart = { getter = .rate, setter = rate' }

unstarted scenario =
  { droplet = Droplet.noDrips
  , bagLevel = (Debug.log "baglevelstart" (BagView.startingState (Calc.startingLevel scenario)))
  , chamberFluid = (Debug.log "chamberfluid start" ChamberView.startingState)
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
    ]
