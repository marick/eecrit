module Animals exposing (main)

import Html exposing (..)
import Html.App exposing (programWithFlags)
import Http
import Json.Decode as Json exposing ((:=))
import Task

main : Program Flags
main =
    Html.App.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

type PageChoice 
  = MainPage

type alias Animal =
  { name : String
  , kind : String
  }

type alias Model =
  { authToken : String
  , baseUri : String
  , animals : Maybe (List Animal)
  }
    
type alias Flags =
  { authToken : String
  , baseUri : String
  }
       
init : Flags -> ( Model, Cmd Msg )
init flags  =
  ( { authToken = flags.authToken
    , baseUri = flags.baseUri
    , animals = Nothing
    }
  , fetch flags.baseUri
  )

type Msg
  = FetchFail Http.Error
  | FetchSucceed (List Animal)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    FetchFail e ->
      let
        _ = Debug.log "fetch fail" (toString e)
      in
        (model, Cmd.none)
    FetchSucceed parsedResult ->
      ( { model | animals = Just parsedResult }
      , Cmd.none
      )


one animal = 
  div []
    [ text animal.name
    , text animal.kind
    ]

view : Model -> Html Msg
view model =
  case model.animals of
    Nothing -> 
      div []
        [ text "...loading..."
        ]
    Just animals ->
      div [] (List.map one animals)
          

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
    
fetch : String -> Cmd Msg
fetch baseUri = 
  let
    url = baseUri ++ "/api/animals"
  in
    Task.perform FetchFail FetchSucceed (Http.get decode url)

decodeAnimal : Json.Decoder Animal
decodeAnimal =
  Json.object2 Animal
    ("name" := Json.string) ("kind" := Json.string)

decode =
  Json.at ["data"] (Json.list decodeAnimal)
         
