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
import Pile.ConstrainedStrings as Constrained
import Pile.Css.H as Css
import Pile.DateHolder as DateHolder

update : AddPageOperation -> Model -> (Model, Cmd Msg)
update op model = 
  case op of
    SetAddedSpecies species ->
      model |> model_speciesToAdd.set species |> noCmd

    UpdateAddedCount countString ->
      model |> adjustCountString countString |> noCmd

    AddFormsForBlankTemplate count species ->
      let
        today = DateHolder.chooseToday model.effectiveDate
      in
        model
          |> addFormsWithIds count (Form.fresh today species)
          |> noCmd
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

adjustCountString : String -> Model -> Model 
adjustCountString string model =
  let
    formValue =
        case Constrained.classify_strictlyPositive string of
          Constrained.Blank ->
            Css.silentlyInvalid string
          Constrained.DoesNotParse ->
            model.numberToAdd -- disallow new character
          Constrained.ParsedButWrong _ ->
            Css.silentlyInvalid string
          Constrained.Parsed _ ->
            Css.freshValue string
  in
    model_numberToAdd.set formValue model
