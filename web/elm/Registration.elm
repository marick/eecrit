module Registration exposing (..)

import Html exposing (Html, text, div)
import Html.Attributes exposing (class)
import Components.AnimalChoiceList as AnimalChoiceList

main : Html a
main =
    div []
        [div [class "elm-app"] [ AnimalChoiceList.view ],
         text "Hi Dawn. Imagine a saline bag here."]
