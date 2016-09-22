module IV.Msg exposing (..)

import Animation

type Msg
    = Go
    | UpdateSpeed String
    | Animate Animation.Msg

