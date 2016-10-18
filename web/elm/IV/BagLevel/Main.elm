module IV.BagLevel.Main exposing (..)

import Animation
import IV.Simulation.BagLevelView as View
import IV.Types exposing (..)
import Time exposing (second)
import IV.Pile.Animation as APile

--- Model

type alias Model =
  { style : Animation.State
  }

animations : Model -> List Animation.State
animations model =
  [model.style]

-- Msg

startingState : Level -> Model 
startingState level =
  { style = Animation.style <| View.animationProperties level }


startSimulation : Model -> Hours -> Level -> Model
startSimulation model hours level =
  { model | style = drainBag hours level model.style }

animationClockTick model tick =
  { model | style = (Animation.update tick) model.style }


drainBag : Hours -> Level -> Animation.State -> Animation.State
drainBag hours level animation =
  let
    ease = APile.easeForHours hours
    change = [Animation.toWith ease (View.animationProperties level)]
  in
    Animation.interrupt change animation
