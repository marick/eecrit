module IV.Apparatus.Main exposing (..)

import IV.Apparatus.Droplet as Droplet
import IV.Apparatus.BagLevel as BagLevel
import IV.Types exposing (..)
import IV.Scenario.Calculations as Calc
import IV.Scenario.Model as Scenario
import IV.Msg exposing (Msg)
import IV.Pile.Effects as Effects
import List

type alias Model =
  { droplet : AnimationState
  , bagLevel : AnimationState
  , rate : DropsPerSecond
  }

droplet' model val =
  { model | droplet = val }
bagLevel' model val =
  { model | bagLevel = val }
rate' model val =
  { model | rate = val }

dropletIn = { getter = .droplet, setter = droplet' }
bagLevelIn = { getter = .bagLevel, setter = bagLevel' }

unstarted scenario =
  { droplet = Droplet.noDrips
  , bagLevel = BagLevel.startingState (Calc.startingLevel scenario)
  , rate = DropsPerSecond 0
  }


animations model = 
  [model.droplet, model.bagLevel]


showTrueFlow : Model -> ( Model, Cmd Msg)
showTrueFlow model =
  Droplet.showTrueFlow model.rate |> Effects.change dropletIn model


startSimulation : Scenario.Model -> Model -> ( Model, Cmd Msg)
startSimulation scenario model =
  Effects.chain model
    [ (dropletIn, Droplet.showTimeLapseFlow)
    , (bagLevelIn, BagLevel.startSimulation <| Calc.drainage scenario)
    ]
    
animationClockTick tick model =
  Effects.chain model
    [ (dropletIn, Droplet.animationClockTick tick)
    , (bagLevelIn, BagLevel.animationClockTick tick)
    ]
