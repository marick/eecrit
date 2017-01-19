module Animals.Logic.AddPageOp exposing
  ( update
  )

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)

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
      model |> addFreshForms count species |> noCmd

        
addFreshForms : Int -> Namelike -> Model -> Model
addFreshForms count species model = 
  let
    (ids, newModel) =
      freshIds count model
      
    displayables =
      ids 
        |> List.map (Form.fresh species)
        |> List.map (Convert.checkedFormToDisplayed)
  in
    newModel
      |> model_displayables.update (Displayables.add displayables)
      |> model_addPageAnimals.update (Displayables.addReferences displayables)
    

