module IV.Types exposing (..)

import Time exposing (second)

type DropsPerSecond
  = DropsPerSecond Float

asDuration : DropsPerSecond -> Float
asDuration (DropsPerSecond perSecond)
  = (1 / perSecond) * second
  
