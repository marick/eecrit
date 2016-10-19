module IV.Apparatus.BagLevel exposing (..)

import Animation
import Animation.Messenger
import IV.Apparatus.BagLevelView as View
import IV.Types exposing (..)
import Time exposing (second)
import IV.Pile.Animation as APile
import IV.Msg exposing (Msg)

--- Model

type alias AnimationState =
  Animation.Messenger.State Msg

type alias Model =
  { style : AnimationState
  }
style' model val = { model | style = val }
                   
animations : Model -> List AnimationState
animations model =
  [model.style]

startingState : Level -> Model 
startingState level =
  { style = Animation.style <| View.animationProperties level }


-- startSimulation : Hours -> Level -> Model -> (Model, Cmd Msg)
startSimulation hours level model =
  ( drainBag hours level model.style |> style' model
  , Cmd.none
  )

animationClockTick tick model =
  let
    (newStyle, cmd) = Animation.Messenger.update tick model.style
  in
    ( style' model newStyle
    , cmd
    )

drainBag : Hours -> Level -> AnimationState -> AnimationState
drainBag hours level animation =
  let
    ease = APile.easeForHours hours
    change = [Animation.toWith ease (View.animationProperties level)]
  in
    Animation.interrupt change animation
