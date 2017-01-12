module Animals.Pages.Common exposing (..)

import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Animals.Msg exposing (..)
import Animals.Model exposing (Model)
import Animals.View.Animal as AnimalView
import Animals.View.Form as FormView
import Animals.Types.Basic exposing (..)

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
    Displayed.Writable form ->
      FormView.view form displayed.animalFlash formActions 
    Displayed.Viewable animal ->
      case animal.displayFormat of
        Animal.Compact ->
          AnimalView.compactView animal displayed.animalFlash
        Animal.Expanded ->
          AnimalView.expandedView animal displayed.animalFlash
         
