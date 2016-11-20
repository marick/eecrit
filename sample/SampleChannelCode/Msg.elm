module C4u.Msg exposing (..)

import Phoenix.Socket
import Json.Encode as JE
import Json.Decode as JD exposing ((:=))

type Msg
    = SetVal Int
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | JoinedChannel
    | ClosedChannel
    | JoinError
    | ChannelError
    | ReceiveMessage JE.Value
