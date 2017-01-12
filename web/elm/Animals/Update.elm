module Animals.Update exposing (..)

import Animals.Model exposing (..)
import Animals.Msg exposing (..)

import Animals.OutsideWorld.H as OutsideWorld
import Animals.OutsideWorld.Cmd as OutsideWorld
import Animals.OutsideWorld.Update as OutsideWorld

import Animals.Pages.Update as Page
import Animals.Pages.PageFlash as Page

import Animals.Animal.Types as Animal
-- import Animals.Animal.Constructors as Animal exposing (noFlash, andFlash)
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Form as Form 
import Animals.Animal.Validation as Validation
import Animals.Animal.Flash as AnimalFlash

import Pile.UpdateHelpers exposing (..)
import Pile.Calendar exposing (EffectiveDate(..))
import Pile.Namelike as Namelike exposing (Namelike)
import Pile.Bulma as Bulma exposing
  (FormStatus(..), FormValue, Urgency(..), Validity(..))

import Set exposing (Set)
import List
import List.Extra as List
import Dict exposing (Dict)

-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  updateWithClearedFlash msg (model_pageFlash.set Page.NoFlash model)

updateWithClearedFlash : Msg -> Model -> ( Model, Cmd Msg )
updateWithClearedFlash msg model =
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
      animalOp op animal model

    WithForm form op ->
      formOp op form model

    Page op ->
      Page.update op model

    Incoming op ->
      OutsideWorld.update op model
        
    NoOp ->
      model ! []


-- Add some inefficiency to make sure that flashes are always removed.
-- (Inefficiency: many ops will change the displayed animal, so the `upsert`
-- is duplicative.)
-- applyAfterRemovingFlash
--   : (Animal.DisplayedAnimal -> Model -> (Model, Cmd msg))
--   -> Animal.DisplayedAnimal -> Model
--   -> (Model, Cmd msg)
-- applyAfterRemovingFlash f displayed model =
--   let
--     newAnimal = noFlash displayed
--     newModel = upsertAnimal newAnimal model
--   in
--     f newAnimal newModel
  
        
animalOp : AnimalOperation -> Animal.Animal -> Model -> (Model, Cmd Msg)
animalOp op animal model = 
  case op of
    RemoveAnimalFlash -> -- this happens automatically, so this is effectively a NoOp
      model |> upsertAnimal animal |> noCmd

    SwitchToReadOnly format ->
      let
        newAnimal = animal_displayFormat.set format animal
      in
        model |> upsertAnimal newAnimal |> noCmd

    StartEditing  ->
      let
        form = Form.extractForm animal
      in
        model |> upsertForm form |> noCmd

    MoreLikeThis ->
      model |> noCmd -- TODO

forwardToForm : Animal.Id -> FormOperation -> Model -> (Model, Cmd Msg)
forwardToForm id op model =
  -- Todo: this should be an idiom
  case Dict.get id model.displayables |> Maybe.map .view of 
    Nothing ->
      model |> noCmd -- Todo: a command to log the error
    Just (Animal.Viewable _) ->
      model |> noCmd
    Just (Animal.Writable form) ->
      formOp op form model

formOp : FormOperation -> Animal.Form -> Model -> (Model, Cmd Msg)
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
            |> form_name.set (Bulma.freshValue s)
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
        displayed = Form.possiblyWithFlash form
      in
        model |> upsertDisplayed displayed |> noCmd

    NoticeCreationResults persistedId ->
      let
        idDuringCreation = form.id
        displayed = Form.possiblyWithFlash (form_id.set persistedId form)
      in
        model
          |> upsertDisplayed displayed
          |> model_allPageAnimals.update (Set.insert persistedId)

          |> deleteDisplayedById idDuringCreation
          |> model_addPageAnimals.update (Set.remove idDuringCreation)

          |> model_pageFlash.set Page.SavedAnimalFlash
          |> noCmd

withSavedForm : Animal.Form -> Model -> (Model, Animal.Animal)
withSavedForm form model =
  ( model |> upsertForm (form_status.set BeingSaved form)
  , Form.appliedForm form
  )

      
addFreshForms : Int -> Namelike -> Model -> Model
addFreshForms count species model = 
  let
    (ids, newModel) =
      freshIds count model
      
    displayables =
      ids 
        |> List.map (Animal.freshForm species)
        |> List.map Animal.formDisplay
  in
    newModel
      |> model_displayables.update (addDisplayables displayables)
      |> model_addPageAnimals.update (addDisplayableIds displayables)
    
-- addAnimalsLikeThis : Int -> Animal.Animal -> Model -> Model
-- addAnimalsLikeThis count templateAnimal model = 
--   let
--     (ids, newModel) =
--       freshIds count model
--     animals =
--       List.map (flip animal_id.set <| templateAnimal) ids
--     addAnimals =
--       Dict.union (displayedAnimalDict animals Animal.editable)
--     addIds =
--       Set.union (Set.fromList ids)
--     validationContext =
--       Validation.context model.animals templateAnimal
--     forms =
--       List.map (Form.extractForm >> Validation.validate validationContext) animals
--     addForms =
--       Dict.union (formDict forms)
--   in
--     newModel
--       |> model_animals.update addAnimals
--       |> model_addPageAnimals.update addIds
--       |> model_forms.update addForms

populateAllAnimalsPage : List Animal.Animal -> Model -> Model 
populateAllAnimalsPage animals model =
  let
    ids =
      List.map .id animals
    compactify animal =
      Animal.Displayed (Animal.Viewable animal) AnimalFlash.NoFlash
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
    
-- displayedAnimalDict : List Animal.Animal -> (Animal.Animal -> Animal.DisplayedAnimal) -> Dict Animal.Id Animal.DisplayedAnimal
-- displayedAnimalDict animals displayedMaker =
--   let
--     ids =
--       List.map .id animals
--     displayedAnimals =
--       List.map displayedMaker animals
--   in
--     List.map2 (,) ids displayedAnimals |> Dict.fromList

             

freshIds : Int -> Model -> (List Animal.Id, Model)    
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

