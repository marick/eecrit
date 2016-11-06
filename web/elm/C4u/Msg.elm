module C4u.Msg exposing (..)

import Phoenix.Socket

type Msg
    = Click
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
