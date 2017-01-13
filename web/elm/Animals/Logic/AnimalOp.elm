module Animals.Logic.AnimalOp exposing
  ( update
  )

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)

import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Conversions as Convert
import Animals.Types.Lenses exposing (..)

import Pile.UpdateHelpers exposing (..)

update : AnimalOperation -> Animal -> Model -> (Model, Cmd Msg)
update op animal model = 
  case op of
    RemoveAnimalFlash -> -- this happens automatically, so this is effectively a NoOp
      model |> Model.upsertAnimal animal |> noCmd

    SwitchToReadOnly format ->
      let
        newAnimal = animal_displayFormat.set format animal
      in
        model |> Model.upsertAnimal newAnimal |> noCmd

    StartEditing  ->
      let
        form = Convert.animalToForm animal
      in
        model |> Model.upsertForm form |> noCmd

    MoreLikeThis ->
      model |> noCmd -- TODO

