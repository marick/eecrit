module IV.Pile.Animation exposing (..)

import Animation
import IV.Types exposing (..)
import Time exposing (second)


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
