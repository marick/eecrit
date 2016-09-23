module IV.Droplet.Msg exposing (..)

import Animation

type Msg
  = ChangeDripRate Float
  | Animate Animation.Msg
