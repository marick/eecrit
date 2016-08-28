module Components.AnimalChoiceList exposing (view)

import Html exposing (Html, text, ul, li, div, h2)
import Html.Attributes exposing (class)
import List
import Components.AnimalChoice


animals : List Components.AnimalChoice.Model
animals =
    [  {name = "Betsy", kind = "cow"}
      ,{name = "Biff", kind = "gelding"}
    ]

renderAnimal : Components.AnimalChoice.Model -> Html a
renderAnimal animal =
    li [] [Components.AnimalChoice.view animal]


renderAnimals : List (Html a)
renderAnimals =
    List.map renderAnimal animals

view : Html a
view =
  div [ class "animal-choice-list" ] [
    h2 [] [ text "Animal Choice List" ],
      ul [] renderAnimals]





-- renderAnimals : List (Html a)
-- renderAnimals =
--     List.map renderAnimal animals
--     [ li [] [ text "Animal 1" ]
--     , li [] [ text "Animal 2" ]
--     , li [] [ text "Animal 3" ] ]

-- view : Html a
-- view =
--   div [class "animal-list" ] [
--        h2 [] [ text "Animal List" ]
--       ,ul [] renderAnimals]
