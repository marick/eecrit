module C4u.Main exposing (..)

import Navigation
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push

import C4u.Msg exposing (..)
import C4u.Navigation as MyNav

import Json.Encode as JE
import Json.Decode as JD exposing ((:=))

-- Model

type alias Model =
    { page : MyNav.PageChoice
    , socket : Phoenix.Socket.Socket Msg
    , notes : List String
    }

-- Update

bareSocket =
  "ws://localhost:4000/socket/websocket"
    |> Phoenix.Socket.init
    |> Phoenix.Socket.withDebug
    |> Phoenix.Socket.on "ping" "c4u" ReceiveMessage

bareChannel =
  "c4u"
    |> Phoenix.Channel.init
    |> Phoenix.Channel.onJoin (always JoinedChannel)
    |> Phoenix.Channel.onClose (always ClosedChannel)
    |> Phoenix.Channel.onJoinError (always JoinError)
    |> Phoenix.Channel.onError (always ChannelError)
       
init : MyNav.PageChoice -> ( Model, Cmd Msg )
init page =
  let
    ( socket, cmd ) = Phoenix.Socket.join bareChannel bareSocket
  in
    ( { page = page
      , socket = socket
      , notes = []
      }
    , Cmd.map PhoenixMsg cmd
    )


setValue value model =
  let
    payload = JE.object [ ("value", JE.int value) ]
    push' = Phoenix.Push.init "value" "c4u" |> Phoenix.Push.withPayload payload
    (socket, cmd) = Phoenix.Socket.push push' model.socket
  in
    ( { model
        | notes = ("setting value to " ++ toString value) :: model.notes
        , socket = socket
      }
    , Cmd.map PhoenixMsg cmd
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case Debug.log "update msg" msg of
    PhoenixMsg msg ->
      let
        ( socket, cmd ) = Phoenix.Socket.update msg model.socket
      in
        ( { model
            | socket = socket
            , notes = toString msg :: model.notes
          }
        , Cmd.map PhoenixMsg cmd
        )

    JoinedChannel ->
      { model | notes = "joined channel" :: model.notes } ! []

    ClosedChannel ->
      { model | notes = "closed channel" :: model.notes } ! []
    JoinError ->
      { model | notes = "error joining channel" :: model.notes } ! []
    ChannelError ->
      { model | notes = "channel error" :: model.notes } ! []

    ReceiveMessage js -> 
      { model | notes = ("got message " ++ toString msg ++ " " ++ toString js) :: model.notes } ! []
    SetVal int ->
      setValue int model

-- Subscriptions
    
subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.socket PhoenixMsg
