module Registration exposing (..)

import Html exposing (Html, text, div)
import Html.App
import Html.Attributes exposing (class)
import Components.AnimalChoiceList as AnimalChoiceList

-- MODEL 

type alias Model =
    {animalChoiceListModel: AnimalChoiceList.Model}

initialModel : Model
initialModel =
    {animalChoiceListModel = AnimalChoiceList.initialModel}

init : (Model, Cmd Msg)
init =
    (initialModel, Cmd.none)

-- UPDATE
        
type Msg =
    AnimalChoiceListMsg AnimalChoiceList.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    AnimalChoiceListMsg animalChoiceMsg ->
      let (updatedModel, cmd) = AnimalChoiceList.update animalChoiceMsg model.animalChoiceListModel
      in ( { model | animalChoiceListModel = updatedModel }, Cmd.map AnimalChoiceListMsg cmd )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- VIEW

view : Model -> Html Msg
view model =
    div [ class "elm-app" ]
        [ Html.App.map AnimalChoiceListMsg (AnimalChoiceList.view model.animalChoiceListModel)]

main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions }

