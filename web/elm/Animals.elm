module Animals exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (programWithFlags)
import Html.Events as Events
import Http
import Json.Decode as Json exposing ((:=))
import String
import Task
import Table exposing (defaultCustomizations)

main : Program Flags
main =
    Html.App.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

type alias Model = 
  { aStringFlag : String
  , aNumberFlag : Int
  }
    
type alias Flags =
  { aStringFlag : String
  , aNumberFlag : String
  }
       
init : Flags -> ( Model, Cmd Msg )
init flags  =
  ( { aStringFlag = flags.aStringFlag
    , aNumberFlag = String.toInt flags.aNumberFlag |> Result.withDefault -1
    }
  , Cmd.none
  )

type Msg
  = NoOp

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      ( model, Cmd.none )


view : Model -> Html Msg
view model =
  p []
    [text <| "Animal has been started with argument \""
       ++ model.aStringFlag ++ "\" and "
       ++ toString(model.aNumberFlag)]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
    
