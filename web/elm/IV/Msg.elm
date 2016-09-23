module IV.Msg exposing (..)

import Animation

type Msg
    = ChangeDripRate
    | ChangedTextField String
    | Animate Animation.Msg

