module IV.Apparatus.BagLevel exposing (..)

import Animation
import Animation.Messenger
import IV.Apparatus.BagView as View
import IV.Types exposing (..)
import Time exposing (second)
import IV.Pile.Animation as APile
import IV.Msg exposing (Msg(..))

startingState : Level -> AnimationState 
startingState level =
  Animation.style <| View.animatableFluidAttributes level

animationClockTick tick model =
  Animation.Messenger.update tick model

startSimulation : Drainage -> AnimationState -> (AnimationState, Cmd Msg)
startSimulation drainage model =
  ( Animation.interrupt (interpretDrainage drainage) model
  , Cmd.none
  )

interpretDrainage drainage =
  case drainage of
    FullyEmptied hours -> 
      [ Animation.toWith
          (APile.easeForHours hours)
          (View.animatableFluidAttributes (Level 0))
      , Animation.Messenger.send FluidRanOut
      ]
          
    PartlyEmptied hours level ->
      [ Animation.toWith
          (APile.easeForHours hours)
          (View.animatableFluidAttributes level)
      ]
      
