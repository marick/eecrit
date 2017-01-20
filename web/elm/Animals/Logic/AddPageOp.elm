module Animals.Logic.AddPageOp exposing
  ( update
  , addFormsWithIds
  )

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Conversions as Convert
import Animals.Types.DisplayedCollections as Displayables
import Animals.Types.Form as Form exposing (Form)

import Pile.UpdateHelpers exposing (..)
import Pile.Calendar as Calendar
import Pile.ConstrainedStrings exposing (updateIfPotentialIntString)
import Pile.Namelike as Namelike exposing (Namelike)

update : AddPageOperation -> Model -> (Model, Cmd Msg)
update op model = 
  case op of
    SetAddedSpecies species ->
      model |> model_speciesToAdd.set species |> noCmd

    UpdateAddedCount countString ->
      model |> updateIfPotentialIntString countString model_numberToAdd |> noCmd

    AddFormsForBlankTemplate count species ->
      model |> addFormsWithIds count (Form.fresh species) |> noCmd

        
addFormsWithIds : Int -> (Id -> Form) -> Model -> Model
addFormsWithIds count formMaker model = 
  let
    (ids, newModel) =
      Model.freshIds count model
      
    displayables =
      ids 
        |> List.map formMaker
        |> List.map Convert.checkedFormToDisplayed
  in
    newModel
      |> model_displayables.update (Displayables.add displayables)
      |> model_addPageAnimals.update (Displayables.addReferences displayables)
    

