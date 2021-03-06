module Animals.Logic.FormOp exposing
  ( forwardToForm
  , update
  )

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Animals.Types.Conversions as Convert
import Animals.Types.Lenses exposing (..)

import Animals.Logic.Validation as Validation

import Animals.OutsideWorld.Cmd as OutsideWorld

import Animals.View.PageFlash as PageFlash

import Pile.Css.H as Css
import Pile.Namelike as Namelike exposing (Namelike)
import Pile.UpdateHelpers exposing (..)
import Pile.DateHolder as DateHolder exposing (DateHolder)

import Set exposing (Set)
import List.Extra as List


forwardToForm : Id -> FormOperation -> Model -> (Model, Cmd Msg)
forwardToForm id op model =
  -- Todo: this should be an idiom
  case getDisplayed id model |> Maybe.map .view of 
    Nothing ->
      model |> noCmd -- Todo: a command to log the error
    Just (Displayed.Viewable _) ->
      model |> noCmd
    Just (Displayed.Writable form) ->
      update op form model

update : FormOperation -> Form -> Model -> (Model, Cmd Msg)
update op form model =
  case op of 
    RemoveFormFlash -> -- this happens automatically, so this is effectively a NoOp
      model |> upsertCheckedForm form |> noCmd

    CancelEdits ->
      model |> Form.givenOriginalAnimal form upsertAnimal |> noCmd

    CancelCreation ->
      model
        |> deleteDisplayedById form.id
        |> deleteFromPage model_addPageAnimals form.id
        |> noCmd

    -- Todo: Factor out similarities between the next two functions.
    StartSavingEdits ->
      let
        updatedAnimal = Convert.formToAnimal form
      in
        model
          |> upsertCheckedForm (form_status.set Css.BeingSaved form)
          |> addCmd (OutsideWorld.saveAnimal form.effectiveDate updatedAnimal)

    StartCreating ->
      let
        newAnimal = Convert.formToAnimal form
      in
        model
          |> upsertCheckedForm (form_status.set Css.BeingSaved form)
          |> addCmd (OutsideWorld.createAnimal form.effectiveDate newAnimal)

    NameFieldUpdate s ->
      let
        okNames = 
          Form.names form -- fine to update to name already attached to this form
        newForm =
          form
            |> form_name.set (Css.freshValue s)
            |> Validation.validate (Validation.context model.displayables okNames)
      in
        model |> upsertCheckedForm newForm |> noCmd

    TentativeTagUpdate s ->
      let
        newForm = form_tentativeTag.set s form
      in
        model |> upsertCheckedForm newForm |> noCmd

    CreateNewTag ->
      let
        newForm =
          form 
            |> form_tags.update (Namelike.perhapsAdd form.tentativeTag)
            |> form_tentativeTag.set ""
      in
        model |> upsertCheckedForm newForm |> noCmd

    DeleteTag name ->
      let
        newForm = form_tags.update (List.remove name) form
      in
        model |> upsertCheckedForm newForm |> noCmd

    OpenFormDatePicker ->
      let
        newForm = form |> form_datePickerState.set DateHolder.PickerOpen
      in
        model |> upsertCheckedForm newForm |> noCmd

    CloseFormDatePicker ->
      let
        newForm = form |> form_datePickerState.set DateHolder.PickerClosed
      in
        model |> upsertCheckedForm newForm |> noCmd

    SelectFormDate date ->
      let
        newForm = form |> form_effectiveDate_chosen.set (DateHolder.At date)
      in 
        model |> upsertCheckedForm newForm |> noCmd

    NoticeSaveResults ->
      let
        displayed = Convert.finishedFormToDisplayed form
      in
        model |> upsertDisplayed displayed |> noCmd

    NoticeCreationResults persistedId ->
      let
        idDuringCreation = form.id
        displayed = Convert.finishedFormToDisplayed (form_id.set persistedId form)
        putOnAllPage = 
          upsertDisplayed displayed
            >> model_allPageAnimals.update (Set.insert persistedId)
        removeFromAddPage = 
          deleteDisplayedById idDuringCreation
            >> model_addPageAnimals.update (Set.remove idDuringCreation)
      in
        case DateHolder.firstAfterSecond form.effectiveDate model.effectiveDate of
          True -> 
            model
              |> removeFromAddPage
              |> model_pageFlash.set PageFlash.SavedAnimalWillNotAppearFlash
              |> noCmd
          False ->
            model
              |> removeFromAddPage
              |> putOnAllPage
              |> model_pageFlash.set PageFlash.SavedAnimalFlash
              |> noCmd

withSavedForm : Form -> Model -> (Model, Animal)
withSavedForm form model =
  ( model |> upsertCheckedForm (form_status.set Css.BeingSaved form)
  , Convert.formToAnimal form
  )

      
