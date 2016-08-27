module Components.AnimalList exposing (view)

import Html exposing (Html, text, ul, li, div, h2)

import Html.Attributes exposing (class)

renderArticles : List (Html a)
renderArticles =
    [ li [] [ text "Animal 1" ]
    , li [] [ text "Animal 2" ]
    , li [] [ text "Animal 3" ] ]

view : Html a
view =
  div [class "animal-list" ] [
       h2 [] [ text "Animal List" ]
      ,ul [] renderArticles]
