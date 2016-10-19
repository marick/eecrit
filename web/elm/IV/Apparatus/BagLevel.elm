module IV.Apparatus.BagLevel exposing (..)

import Animation
import IV.Apparatus.BagLevelView as View
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


startSimulation : Hours -> Level -> Model -> Model
startSimulation hours level model =
  { model | style = drainBag hours level model.style }

animationClockTick tick model =
  { model | style = (Animation.update tick) model.style }


drainBag : Hours -> Level -> Animation.State -> Animation.State
drainBag hours level animation =
  let
    ease = APile.easeForHours hours
    change = [Animation.toWith ease (View.animationProperties level)]
  in
    Animation.interrupt change animation
