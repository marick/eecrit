module IV.Apparatus.BagLevel exposing (..)

import Animation
import Animation.Messenger
import IV.Apparatus.BagLevelView as View
import IV.Types exposing (..)
import Time exposing (second)
import IV.Pile.Animation as APile
import IV.Msg exposing (Msg(..))

type alias Model = AnimationState
                   
startingState : Level -> Model 
startingState level =
  Animation.style <| View.animationProperties level

animationClockTick tick model =
  Animation.Messenger.update tick model

startSimulation : Drainage -> Model -> (Model, Cmd Msg)
startSimulation drainage model =
  ( Animation.interrupt (interpretDrainage drainage) model
  , Cmd.none
  )

interpretDrainage drainage =
  case drainage of
    FullyEmptied hours -> 
      [ Animation.toWith
          (APile.easeForHours hours)
          (View.animationProperties (Level 0))
      , Animation.Messenger.send FluidRanOut
      ]
          
    PartlyEmptied hours level ->
      [ Animation.toWith
          (APile.easeForHours hours)
          (View.animationProperties level)
      ]
      
