module IV.Droplet.Msg exposing (..)

import Animation
import IV.Droplet.Model exposing (Model)

type Msg
  = ChangeDripRate Float
  | AnimationClockTick Animation.Msg

