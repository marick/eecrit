module Components.AnimalChoiceList exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Components.AnimalChoice as AnimalChoice
import Http
import Task
import Json.Decode as Json exposing ((:=))
import Debug

-- MODEL

type alias Model =
    {animalChoices: List AnimalChoice.Model}

initialModel : Model
initialModel =
    { animalChoices = [] }


-- UPDATE

type Msg
    = NoOp
    | Fetch
    | FetchSucceed (List AnimalChoice.Model)
    | FetchFail Http.Error
    | RouteToNewPage SubPage

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            (model, Cmd.none)
        Fetch ->
            (model, fetchAnimalChoiceList)
        FetchSucceed animalChoiceList ->
            (Model animalChoiceList, Cmd.none)
        FetchFail error ->
            case error of
                Http.UnexpectedPayload errorMessage ->
                    Debug.log errorMessage
                    (model, Cmd.none)
                _ ->
                    (model, Cmd.none)
        _ ->
            (model, Cmd.none)

-- VIEW

type SubPage
    = ListView
    | ShowView AnimalChoice.Model

animalLink : AnimalChoice.Model -> Html Msg
animalLink animal =
    a [ href ("animal/" ++ animal.name ++ "/show")
      , onClick (RouteToNewPage (ShowView animal))
      ]
      [ text " (Show)" ]
              
renderAnimal : AnimalChoice.Model -> Html Msg
renderAnimal animal =
    li [] [
         div [] [AnimalChoice.view animal, animalLink animal]
        ]

renderAnimals : Model -> List (Html Msg)
renderAnimals model =
    List.map renderAnimal model.animalChoices

view : Model -> Html Msg
view model =
  div [ class "animal-choice-list" ]
      [ h2 [] [ text "Animal Choice List" ]
      , ul [] (renderAnimals model)]

-- HTTP

fetchAnimalChoiceList : Cmd Msg
fetchAnimalChoiceList =
    let
        url = "/api/animals"
    in
        Task.perform FetchFail FetchSucceed (Http.get decodeAnimalChoiceFetch url)


decodeAnimalChoiceFetch : Json.Decoder (List AnimalChoice.Model)
decodeAnimalChoiceFetch =
    Json.at ["data"] decodeAnimalChoiceList

decodeAnimalChoiceList: Json.Decoder (List AnimalChoice.Model)
decodeAnimalChoiceList =
    Json.list decodeAnimalChoiceData

decodeAnimalChoiceData : Json.Decoder AnimalChoice.Model
decodeAnimalChoiceData =
    Json.object2 AnimalChoice.Model
        ("name" := Json.string)
        ("kind" := Json.string)

