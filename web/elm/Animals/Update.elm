module Animals.Update exposing (..)

import Animals.Model exposing (..)
import Animals.Msg exposing (..)

import Animals.OutsideWorld.H as OutsideWorld
import Animals.OutsideWorld.Cmd as OutsideWorld
import Animals.OutsideWorld.Update as OutsideWorld

import Animals.Pages.Update as Page
import Animals.View.PageFlash as PageFlash

import Animals.Logic.AnimalOp as AnimalOp

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Animals.Types.Lenses exposing (..)
import Animals.Types.Conversions as Convert
import Animals.Logic.Validation as Validation
import Animals.View.AnimalFlash as AnimalFlash

import Pile.UpdateHelpers exposing (..)
import Pile.Calendar exposing (EffectiveDate(..))
import Pile.Namelike as Namelike exposing (Namelike)
import Pile.Css.H as Css
import Pile.Css.Bulma as Css

import Set exposing (Set)
import List
import List.Extra as List
import Dict exposing (Dict)
-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  updateWithClearedPageFlash msg (model_pageFlash.set PageFlash.NoFlash model)

updateWithClearedPageFlash : Msg -> Model -> ( Model, Cmd Msg )
updateWithClearedPageFlash msg model =
  case msg of
    SetToday value ->
      model |> model_today.set value |> noCmd
    SetAnimals animals ->
      model |> populateAllAnimalsPage animals |> noCmd

    ToggleDatePicker ->
      model |> model_datePickerOpen.update not |> noCmd
    SelectDate date ->
      model |> model_effectiveDate.set (At date) |> noCmd
      
    SetNameFilter s ->
      model |> model_nameFilter.set s |> noCmd
    SetTagFilter s ->
      model |> model_tagFilter.set s |> noCmd
    SetSpeciesFilter s ->
      model |> model_speciesFilter.set s |> noCmd

    AnimalGotSaved (OutsideWorld.AnimalUpdated id) ->
      forwardToForm id NoticeSaveResults model 

    AnimalGotCreated (OutsideWorld.AnimalCreated tempId realId) ->
      forwardToForm tempId (NoticeCreationResults realId) model

    AddNewAnimals count species ->
      model |> addFreshForms count species |> noCmd
          
    WithAnimal animal op ->
      AnimalOp.update op animal model

    WithForm form op ->
      formOp op form model

    Page op ->
      Page.update op model

    Incoming op ->
      OutsideWorld.update op model
        
    NoOp ->
      model ! []


        
forwardToForm : Id -> FormOperation -> Model -> (Model, Cmd Msg)
forwardToForm id op model =
  -- Todo: this should be an idiom
  case Dict.get id model.displayables |> Maybe.map .view of 
    Nothing ->
      model |> noCmd -- Todo: a command to log the error
    Just (Displayed.Viewable _) ->
      model |> noCmd
    Just (Displayed.Writable form) ->
      formOp op form model

formOp : FormOperation -> Form -> Model -> (Model, Cmd Msg)
formOp op form model =
  case op of 
    RemoveFormFlash -> -- this happens automatically, so this is effectively a NoOp
      model |> upsertForm form |> noCmd

    CancelEdits ->
      let
        original = form.originalAnimal
      in
        case original of
          Nothing ->
            model |> noCmd -- Todo: add error handling for impossible case
          Just animal -> 
            model |> upsertAnimal animal |> noCmd

    StartSavingEdits ->
      model |> withSavedForm form |> makeCmd OutsideWorld.saveAnimal

    CancelCreation ->
      model
        |> deleteDisplayedById form.id
        |> deleteFromPage model_addPageAnimals form.id
        |> noCmd
          
    StartCreating ->
      model |> withSavedForm form |> makeCmd OutsideWorld.createAnimal

    NameFieldUpdate s ->
      let
        newForm =
          form
            |> form_name.set (Css.freshValue s)
            |> Validation.validate (Validation.context model.displayables form.originalAnimal)
      in
        model |> upsertForm newForm |> noCmd

    TentativeTagUpdate s ->
      let
        newForm = form_tentativeTag.set s form
      in
        model |> upsertForm newForm |> noCmd

    CreateNewTag ->
      let
        newForm =
          form 
            |> form_tags.update (Namelike.perhapsAdd form.tentativeTag)
            |> form_tentativeTag.set ""
      in
        model |> upsertForm newForm |> noCmd

    DeleteTag name ->
      let
        newForm = form_tags.update (List.remove name) form
      in
        model |> upsertForm newForm |> noCmd

    NoticeSaveResults ->
      let
        displayed = Convert.formToDisplayed form
      in
        model |> upsertDisplayed displayed |> noCmd

    NoticeCreationResults persistedId ->
      let
        idDuringCreation = form.id
        displayed = Convert.formToDisplayed (form_id.set persistedId form)
      in
        model
          |> upsertDisplayed displayed
          |> model_allPageAnimals.update (Set.insert persistedId)

          |> deleteDisplayedById idDuringCreation
          |> model_addPageAnimals.update (Set.remove idDuringCreation)

          |> model_pageFlash.set PageFlash.SavedAnimalFlash
          |> noCmd

withSavedForm : Form -> Model -> (Model, Animal)
withSavedForm form model =
  ( model |> upsertForm (form_status.set Css.BeingSaved form)
  , Convert.formToAnimal form
  )

      
addFreshForms : Int -> Namelike -> Model -> Model
addFreshForms count species model = 
  let
    (ids, newModel) =
      freshIds count model
      
    displayables =
      ids 
        |> List.map (Form.fresh species)
        |> List.map Displayed.fromForm
  in
    newModel
      |> model_displayables.update (addDisplayables displayables)
      |> model_addPageAnimals.update (addDisplayableIds displayables)
    

populateAllAnimalsPage : List Animal -> Model -> Model 
populateAllAnimalsPage animals model =
  let
    ids =
      List.map .id animals
    compactify animal =
      Displayed (Displayed.Viewable animal) AnimalFlash.NoFlash
    displayables =
      List.map compactify animals
  in
    { model
      | displayables = displayableDict displayables
      , allPageAnimals = displayableIdSet displayables
    }

displayableDict displayables =
  let
    ids = List.map displayed_id.get displayables
  in
    List.map2 (,) ids displayables |> Dict.fromList

displayableIdSet displayables =
  List.map displayed_id.get displayables |> Set.fromList 

addDisplayables displayables existingDict =
  displayables |> displayableDict |> Dict.union existingDict
    
addDisplayableIds displayables existingSet =
  displayables |> displayableIdSet |> Set.union existingSet
    
             

freshIds : Int -> Model -> (List Id, Model)    
freshIds n model =
  let 
    uniquePrefix = "New_animal_"
    name i = uniquePrefix ++ toString i
    ids =
      List.range (model.animalsEverAdded + 1) (model.animalsEverAdded + n)
        |> List.map name
    newModel = model_animalsEverAdded.update ((+) n) model
  in
    (ids, newModel)

