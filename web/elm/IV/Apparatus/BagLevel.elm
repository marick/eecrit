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

animationClockTick tick model =
  let
    (newStyle, cmd) = Animation.Messenger.update tick model.style
  in
    ( style' model newStyle
    , cmd
    )

startSimulation : Drainage -> Model -> (Model, Cmd Msg)
startSimulation drainage model =
  ( Animation.interrupt (interpretDrainage drainage) model.style |> style' model
  , Cmd.none
  )

interpretDrainage drainage =
  case drainage of
    FullyEmptied hours -> 
      [ Animation.toWith
          (APile.easeForHours hours)
          (View.animationProperties (Level 0))
      ]
          
    PartlyEmptied hours level ->
      [ Animation.toWith
          (APile.easeForHours hours)
          (View.animationProperties level)
      ]
      
