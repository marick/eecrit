module IV.Pile.Animation exposing (..)

import Animation
import Animation.Messenger
import IV.Types exposing (..)
import Time exposing (second)
import IV.Msg exposing (Msg)


type alias AnimationState =
  Animation.Messenger.State Msg

simulationDuration : Hours -> Float
simulationDuration (Hours hours) =
  hours * 1.5 * second

linearEasing : Float -> Animation.Interpolation
linearEasing duration =
  Animation.easing
    {
      ease = identity
    , duration = duration
    }
    
easeForHours : Hours -> Animation.Interpolation
easeForHours hours =
  linearEasing <| simulationDuration hours
