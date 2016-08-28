module Components.AnimalChoiceList exposing (view)

import Html exposing (Html, text, ul, li, div, h2)
import Html.Attributes exposing (class)
view : Html a
view =
  div [ class "animal-choice-list" ] [
    h2 [] [ text "Animal Choice List" ],
      ul []
        [ li [] [ text "Animal 1" ]
        , li [] [ text "Animal 2" ]
        , li [] [ text "Animal 3" ] ] ]
