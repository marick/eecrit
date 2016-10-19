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
style' model val = { model | style = val }
                   
animations : Model -> List Animation.State
animations model =
  [model.style]

startingState : Level -> Model 
startingState level =
  { style = Animation.style <| View.animationProperties level }


startSimulation : Hours -> Level -> Model -> (Model, Cmd msg)
startSimulation hours level model =
  ( drainBag hours level model.style |> style' model
  , Cmd.none
  )

animationClockTick tick model =
  ( Animation.update tick model.style |> style' model
  , Cmd.none
  )


drainBag : Hours -> Level -> Animation.State -> Animation.State
drainBag hours level animation =
  let
    ease = APile.easeForHours hours
    change = [Animation.toWith ease (View.animationProperties level)]
  in
    Animation.interrupt change animation
