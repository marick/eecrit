module Components.AnimalChoiceList exposing (..)

import Html exposing (Html, text, ul, li, div, h2, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Components.AnimalChoice as AnimalChoice

type alias Model =
    {animalChoices: List AnimalChoice.Model}

type Msg
    = NoOp
    | Fetch

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NoOp ->
            (model, Cmd.none)
        Fetch ->
            (animals, Cmd.none)

animals : Model
animals =
    { animalChoices = 
          [  {name = "Betsy", kind = "cow"}
          ,{name = "Biff", kind = "gelding"}
          ]}

renderAnimal : AnimalChoice.Model -> Html a
renderAnimal animal =
    li [] [AnimalChoice.view animal]

renderAnimals : Model -> List (Html a)
renderAnimals model =
    List.map renderAnimal model.animalChoices

initialModel : Model
initialModel =
    { animalChoices = [] }
                

view : Model -> Html Msg
view model =
  div [ class "animal-choice-list" ]
      [ h2 [] [ text "Animal Choice List" ]
      , button [onClick Fetch, class "btn btn-primary"] [text "Fetch"]
      , ul [] (renderAnimals model)]
