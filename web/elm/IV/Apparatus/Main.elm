module IV.Apparatus.Main exposing (..)

import IV.Apparatus.Droplet as Droplet
import IV.Apparatus.BagLevel as BagLevel
import IV.Types exposing (..)
import IV.Scenario.Calculations as Calc
import IV.Scenario.Model as Scenario

type alias Model =
  { droplet : AnimationState
  , bagLevel : AnimationState
  }

unstarted scenario =
  { droplet = Droplet.noDrips
  , bagLevel = BagLevel.startingState (Calc.startingLevel scenario)
  }

droplet' model val =
  { model | droplet = val }
bagLevel' model val =
  { model | bagLevel = val }

  

animations model = 
  [model.droplet, model.bagLevel]

showTrueFlow dps model = 
  let
    (newDroplet, cmd) = Droplet.showTrueFlow dps model.droplet
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
