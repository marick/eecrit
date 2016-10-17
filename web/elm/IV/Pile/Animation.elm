module IV.Pile.Animation exposing (..)

import Animation
import IV.Types exposing (..)
import Time exposing (second)


simulationDuration : Hours -> Float
simulationDuration (Hours hours) =
  hours * 1.5 * second

easeForHours : Hours -> Animation.Interpolation
easeForHours hours =
  Animation.easing
    {
      ease = identity
    , duration = simulationDuration hours
    }
