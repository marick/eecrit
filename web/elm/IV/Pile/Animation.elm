module IV.Pile.Animation exposing (..)

import Animation
import IV.Types exposing (..)
import Time exposing (second)

easeForHours (Hours hours) =
  Animation.easing
    {
      ease = identity
    , duration = hours * 1.5 * second
    }
