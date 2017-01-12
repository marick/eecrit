module Animals.Pages.Common exposing (..)

import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)
import Animals.Model exposing (Model)
import Animals.View.Animal as AnimalView
import Animals.View.Form as FormView

import Dict
import Html exposing (Html)
import Set exposing (Set)


pageAnimals : (Model -> Set Id) -> Model -> List Displayed
pageAnimals pageAnimalsGetter model =
  model
    |> pageAnimalsGetter
    |> Set.toList 
    |> List.map (\ id -> Dict.get id model.displayables)
    |> List.filterMap identity

individualAnimalView : Model -> (FormOperation, FormOperation) -> Displayed
                     -> Html Msg
individualAnimalView model formActions displayed =
  case displayed.view of
    Writable form ->
      FormView.view form displayed.animalFlash formActions 
    Viewable animal ->
      case animal.displayFormat of
        Compact ->
          AnimalView.compactView animal displayed.animalFlash
        Expanded ->
          AnimalView.expandedView animal displayed.animalFlash
         
