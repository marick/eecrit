module Animals.Logic.DisplayedOp exposing (forwardToDisplayed)

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Animals.Types.DisplayedCollections as Displayables
import Animals.Types.Conversions as Convert
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Lenses exposing (..)

import Animals.Pages.H as Page
import Animals.Pages.Navigation as Page
import Animals.View.AnimalFlash as AnimalFlash

import Pile.UpdateHelpers exposing (..)
import Pile.ConstrainedStrings as Constrained

{-| Note that displayed operations do NOT empty the flash. This is kind of a
    kludge.
-}

forwardToDisplayed : Id -> DisplayedOperation -> Model -> (Model, Cmd Msg)
forwardToDisplayed id op model =
  case getDisplayed id model of
    Nothing -> 
      model |> noCmd -- Todo: a command to log the error
    Just displayed -> 
      update op displayed model

update : DisplayedOperation -> Displayed -> Model -> (Model, Cmd Msg)
update op displayed model =
  case op of
    BeginGatheringCopyInfo ->
        model
          |> upsertDisplayed (withGatherFlash displayed "1")
          |> noCmd

    UpdateCopyCount countString ->
        model
          |> upsertDisplayed (withValidatedGatherFlash displayed countString)
          |> noCmd

    AddFormsBasedOnAnimal count ->
      model
        |> addAnimalForms displayed count
        |> addCmd (Page.toPageChangeCmd Page.AddPage)

addAnimalForms source count model =
  let
    sourceForm =
      source
        |> Convert.displayedToForm
        |> form_name.set (Form.emptyNameWithNotice)
        |> form_intendedVersion.set 1

    (ids, newModel) =
      Model.freshIds count model
                      
    displayables = 
      ids
        |> List.map (\id -> form_id.set id sourceForm)
        |> List.map Convert.checkedFormToDisplayed
  in
    newModel
      |> model_displayables.update (Displayables.add displayables)
      |> model_addPageAnimals.update (Displayables.addReferences displayables)
             
withGatherFlash displayed string = 
  displayed_flash.set
    (AnimalFlash.CopyInfoNeeded (displayed_id.get displayed) string)
    displayed

withValidatedGatherFlash displayed string = 
  case Constrained.isPotentialIntString string of
    True -> withGatherFlash displayed string
    False -> displayed
