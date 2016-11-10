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

type PageChoice 
  = MainPage

type alias Animal =
  { id : Int
  , name : String
  , nickname : String
  , kind : String
  }

type alias Model =
  { authToken : String
  , baseUri : String
  , animals : Maybe (List Animal)
  , tableState : Table.State
  , nameFilter : String
  , kindFilter : String
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
    , tableState = Table.initialSort "Name"
    , nameFilter = ""
    , kindFilter = ""
    }
  , fetch flags.baseUri
  )

type Msg
  = FetchFail Http.Error
  | FetchSucceed (List Animal)
  | SetTableState Table.State
  | SetNameFilter String
  | SetKindFilter String

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

    SetTableState state ->
      ( { model | tableState = state }
      , Cmd.none
      )    

    SetNameFilter s ->
      ( { model | nameFilter = s }
      , Cmd.none
      )

    SetKindFilter s ->
      ( { model | kindFilter = s }
      , Cmd.none
      )


view : Model -> Html Msg
view model =
  case model.animals of
    Nothing -> 
      div [] [ text "...loading..." ]
    Just animals ->
      viewAnimals model animals

viewAnimals model animals =
  let
    lowerNameFilter = String.toLower model.nameFilter
    lowerKindFilter = String.toLower model.kindFilter

    filterBy getter filterString =
      List.filter (getter >> String.toLower >> String.contains filterString)

    acceptable =
      animals
        |> filterBy .name lowerNameFilter
        |> filterBy .kind lowerKindFilter
  in
    div []
      [ div [class "row"]
          [ div [class "input-group"]
              [ span [class "input-group-addon"] [text "Filter by name"]
              , input [ type' "text"
                      , value model.nameFilter
                      , Events.onInput SetNameFilter]
                  []
              , span [class "input-group-addon"] [text "Filter by kind"]
              , input [ type' "text"
                      , value model.kindFilter
                      , Events.onInput SetKindFilter]
                  []
              ]
          ]
      , Table.view config model.tableState acceptable
      ]


customizations =       
  { defaultCustomizations
    | tableAttrs = [class "table table-striped"]
  }

config : Table.Config Animal Msg
config =
  Table.customConfig
    { toId = .name
    , toMsg = SetTableState
    , columns =
        [ caseInsensitiveColumn "Name" .name
        -- Nickname column seems pointless
        -- , caseInsensitiveColumn "Nickname" .nickname
        , caseInsensitiveColumn "Kind" .kind
        , buttonColumn
        ]
    , customizations = customizations
    }


buttonColumn = 
  Table.veryCustomColumn
    { name = ""
    , viewData = buttons
    , sorter = Table.unsortable
    }

buttons animal =
  Table.HtmlDetails [] [strong [] [text ("edit etc buttons for id " ++ toString animal.id)]]

caseInsensitiveColumn : String -> (Animal -> String) -> Table.Column Animal Msg
caseInsensitiveColumn name accessor =
  Table.customColumn
    { name = name
    , viewData = accessor
    , sorter = Table.increasingOrDecreasingBy (accessor >> String.toLower)
    }

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
    
fetch : String -> Cmd Msg
fetch baseUri = 
  let
    url = baseUri ++ "/api/animals"
  in
    Task.perform FetchFail FetchSucceed (Http.get decode url)

nullOrEmptyDecoder : Json.Decoder String
nullOrEmptyDecoder =
  Json.oneOf
    [ Json.null ""
    , Json.string
    ]
      
decodeAnimal : Json.Decoder Animal
decodeAnimal =
  Json.object4 Animal
    ("id" := Json.int)
    ("name" := Json.string)
    ("nickname" := nullOrEmptyDecoder)
    ("kind" := Json.string)


      
decode =
  Json.at ["data"] (Json.list decodeAnimal)
         
