module IV.Apparatus.Main exposing
  ( Model
  , animations
  , unstarted
  , showTrueFlow
  , startSimulation
  , animationClockTick
  , changeDripRate
  )

import IV.Apparatus.Droplet as Droplet
import IV.Apparatus.BagLevel as BagLevel
import IV.Types exposing (..)
import IV.Scenario.Calculations as Calc
import IV.Scenario.Model as Scenario
import IV.Msg exposing (Msg)
import IV.Pile.CmdFlow as CmdFlow
import List

animations model = 
  [model.droplet, model.bagLevel]

-- Model
    
type alias Model =
  { droplet : AnimationState
  , bagLevel : AnimationState
  , rate : DropsPerSecond
  }

droplet' model val = { model | droplet = val }
bagLevel' model val = { model | bagLevel = val }
rate' model val = { model | rate = val }

dropletPart = { getter = .droplet, setter = droplet' }
bagLevelPart = { getter = .bagLevel, setter = bagLevel' }
ratePart = { getter = .rate, setter = rate' }

unstarted scenario =
  { droplet = Droplet.noDrips
  , bagLevel = BagLevel.startingState (Calc.startingLevel scenario)
  , rate = DropsPerSecond 0
  }

-- Updates

showTrueFlow : Model -> ( Model, Cmd Msg)
showTrueFlow model =
  Droplet.showTrueFlow model.rate |> CmdFlow.change dropletPart model

changeDripRate : DropsPerSecond -> Model -> ( Model, Cmd Msg )
changeDripRate dropsPerSecond model =
  rate' model dropsPerSecond ! []

startSimulation : Scenario.Model -> Model -> ( Model, Cmd Msg)
startSimulation scenario model =
  CmdFlow.chainLike model
    [ (dropletPart, Droplet.showTimeLapseFlow)
    , (bagLevelPart, BagLevel.startSimulation <| Calc.drainage scenario)
    ]
    
animationClockTick tick model =
  CmdFlow.chainLike model
    [ (dropletPart, Droplet.animationClockTick tick)
    , (bagLevelPart, BagLevel.animationClockTick tick)
    ]
