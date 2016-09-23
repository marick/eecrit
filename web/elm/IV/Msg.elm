module IV.Msg exposing (..)

import Animation

type Msg
    = PressedGoButton
    | ChangedTextField String
    | Animate Animation.Msg

