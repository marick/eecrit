module IV.Apparatus.Main exposing (..)

import IV.Apparatus.Droplet as Droplet
import IV.Apparatus.BagLevel as BagLevel
import IV.Types exposing (..)
import IV.Scenario.Calculations as Calc
import IV.Scenario.Model as Scenario

type alias Model =
  { droplet : AnimationState
  , bagLevel : AnimationState
  , rate : DropsPerSecond
  }

unstarted scenario =
  { droplet = Droplet.noDrips
  , bagLevel = BagLevel.startingState (Calc.startingLevel scenario)
  , rate = DropsPerSecond 0
  }

droplet' model val =
  { model | droplet = val }
bagLevel' model val =
  { model | bagLevel = val }
rate' model val =
  { model | rate = val }

animations model = 
  [model.droplet, model.bagLevel]

    
showTrueFlow model = 
  let
    (newDroplet, cmd) = Droplet.showTrueFlow model.rate model.droplet
  in
    ( { model | droplet = newDroplet }
    , cmd
    )

startSimulation scenario model = 
  let
    (newDroplet, dropletCmd) = Droplet.showTimeLapseFlow model.droplet
    (newBagLevel, bagLevelCmd) = BagLevel.startSimulation (Calc.drainage scenario) model.bagLevel
  in
    ( { model
        | droplet = newDroplet
        , bagLevel = newBagLevel
      }
    , Cmd.batch [dropletCmd, bagLevelCmd ]
    )
    
animationClockTick tick model =
  let
    (newDroplet, dropletCmd) = Droplet.animationClockTick tick model.droplet
    (newBagLevel, bagLevelCmd) = BagLevel.animationClockTick tick model.bagLevel
  in
    ( { model
        | droplet = newDroplet
        , bagLevel = newBagLevel
      }
    , Cmd.batch [dropletCmd, bagLevelCmd ]
    )
