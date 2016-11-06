module C4u.Main exposing (..)

import Navigation
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push

import C4u.Msg exposing (..)
import C4u.Navigation as MyNav


-- Model

type alias Model =
    { page : MyNav.PageChoice
    , socket : Phoenix.Socket.Socket Msg
    }

-- Update

init : MyNav.PageChoice -> ( Model, Cmd Msg )
init page =
  ( { page = page
    , socket = Phoenix.Socket.withDebug <| Phoenix.Socket.init "ws://localhost:4000/socket/websocket" }
  , Cmd.none
  )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case Debug.log "update msg" msg of
    Click ->
      ( model ! [])
    PhoenixMsg msg ->
      let
        ( socket, cmd ) = Phoenix.Socket.update msg model.socket
      in
        ( { model | socket = socket }
        , Cmd.map PhoenixMsg cmd
        )
    
        
-- Subscriptions
    
subscriptions : Model -> Sub Msg
subscriptions model =
  Phoenix.Socket.listen model.socket PhoenixMsg
