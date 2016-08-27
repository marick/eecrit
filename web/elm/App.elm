module App exposing (..)

import Html exposing (Html, text, div)
import Html.Attributes exposing (class)

import Components.AnimalList as AnimalList

main : Html a
main =
    div []
        [div [class "elm-app"] [ AnimalList.view ],
         text "Hi Dawn. Imagine a saline bag here."]
