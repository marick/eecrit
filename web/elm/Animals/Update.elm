module Animals.Update exposing (..)

import Animals.Model exposing (..)
import Animals.Msg exposing (..)

import Animals.OutsideWorld.Declare as OutsideWorld
import Animals.OutsideWorld.Define as OutsideWorld

import Animals.Pages.Update as Page
import Animals.Pages.PageFlash as Page

import Animals.Animal.Types as Animal
import Animals.Animal.Constructors as Animal exposing (noFlash, andFlash)
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Form as Form 
import Animals.Animal.Validation as Validation

import Pile.UpdateHelpers exposing (..)
import Pile.Calendar exposing (EffectiveDate(..))
import Pile.Namelike as Namelike
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
    SetAnimals (Ok animals) ->
      model |> populateAllAnimalsPage animals |> noCmd
    SetAnimals (Err e) ->
      model |> httpError "I could not retrieve animals." e |> noCmd

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

    NoticeAnimalSaveResults (Ok (OutsideWorld.AnimalUpdated id)) ->
      case Dict.get id model.forms of
        Nothing ->
          model |> noCmd -- Todo: a command to log the error
        Just form ->
          updateWithClearedFlash (WithForm form NoticeSaveResults) model

    NoticeAnimalCreationResults (Ok (OutsideWorld.AnimalCreated tempId realId)) ->
      case Dict.get tempId model.forms of
        Nothing ->
          model |> noCmd -- Todo: a command to log the error
        Just form ->
          updateWithClearedFlash (WithForm form <| NoticeCreationResults realId) model

    -- TODO: Make this an animal flash instead of a page flash?
    -- More noticeable, but only works if there's just one animal being
    -- saved at a time. 
    NoticeAnimalSaveResults (Err e) ->
      model |> httpError "I could not save the animal." e |> noCmd

    NoticeAnimalCreationResults (Err e) ->
      model |> httpError "I could not create the animal." e |> noCmd

    AddNewAnimals count species ->
      let
        -- TODO: create an AlmostAnimal type instead of "this id MUST..."
        template =
          { id = "This id MUST be replaced"
          , version = 0
          , name = ""
          , species = species
          , tags = []
          , properties = Dict.empty
          }
      in
        model |> addAnimalsLikeThis count template |> noCmd
          
    WithAnimal displayed op ->
        applyAfterRemovingFlash (animalOp op) displayed model

    WithForm form op ->
      case Dict.get form.id model.animals of
        Nothing ->
          model |> noCmd -- Todo: a command to log the error
        Just displayed ->
          applyAfterRemovingFlash (formOp op form) displayed model 

    Page msg ->
      Page.update msg model
      
    NoOp ->
      model ! []


-- Add some inefficiency to make sure that flashes are always removed.
-- (Inefficiency: many ops will change the displayed animal, so the `upsert`
-- is duplicative.)
applyAfterRemovingFlash f displayed model =
  let
    newAnimal = noFlash displayed
    newModel = upsertAnimal newAnimal model
  in
    f newAnimal newModel
  
        
animalOp : AnimalOperation -> Animal.DisplayedAnimal -> Model -> (Model, Cmd Msg)
animalOp op displayed model = 
  case op of
    RemoveFlash ->
      model |> upsertAnimal displayed |> noCmd

    SwitchToReadOnly format ->
      let
        newAnimal = displayedAnimal_format.set format displayed
      in
        model |> upsertAnimal newAnimal |> noCmd

    StartEditing  ->
      let
        newAnimal = displayed |> displayedAnimal_format.set Animal.Editable
        form = Form.extractForm displayed.animal
      in
        model |> upsertAnimal newAnimal |> upsertForm form |> noCmd

    MoreLikeThis ->
      model |> noCmd -- TODO

formOp : FormOperation -> Animal.Form -> Animal.DisplayedAnimal -> Model
       -> (Model, Cmd Msg)
formOp op form displayed model =
  case Debug.log "oop" op of 
    CancelEdits ->
      let
        newDisplayed = displayed |> displayedAnimal_format.set Animal.Expanded
      in
        model |> upsertAnimal newDisplayed |> deleteForm form |> noCmd
    StartSavingEdits ->
      model |> withSavedForm form |> makeCmd OutsideWorld.saveAnimal

    CancelCreation ->
      let
        id = displayedAnimal_id.get displayed
      in
        model
          |> deleteForm form
          |> deleteAnimal displayed
          |> model_addPageAnimals.update (Set.remove id)
          |> noCmd
          
    StartCreating ->
      model |> withSavedForm form |> makeCmd OutsideWorld.createAnimal

    NameFieldUpdate s ->
      let
        newForm =
          form
            |> form_name.set (Bulma.freshValue s)
            |> Validation.validate (Validation.context model.animals displayed.animal)
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
        newDisplayed = displayedAnimalFromForm form
      in
        model |> upsertAnimal newDisplayed |> deleteForm form |> noCmd

    NoticeCreationResults realId ->
      let
        originalId = form.id
        newDisplayed = displayedAnimalFromForm form |> displayedAnimal_id.set realId
      in
        model
          |> deleteAnimalById originalId |> deleteFormById originalId
          |> upsertAnimal newDisplayed
          |> model_addPageAnimals.update (Set.remove originalId)
          |> model_allPageAnimals.update (Set.insert realId)
          |> model_pageFlash.set Page.SavedAnimalFlash
          |> noCmd

-----------------------          

withSavedForm : Animal.Form -> Model -> (Model, Animal.Animal)
withSavedForm form model =
  ( model |> upsertForm (form_status.set BeingSaved form)
  , Form.appliedForm form
  )

displayedAnimalFromForm form =
  { animal = Form.appliedForm form
  , format = Animal.Expanded
  , animalFlash = Form.saveFlash form
  }

      

addAnimalsLikeThis count templateAnimal model = 
  let
    (ids, newModel) =
      freshIds count model
    animals =
      List.map (flip animal_id.set <| templateAnimal) ids
    addAnimals =
      Dict.union (displayedAnimalDict animals Animal.editable)
    addIds =
      Set.union (Set.fromList ids)
    validationContext =
      Validation.context model.animals templateAnimal
    forms =
      List.map (Form.extractForm >> Validation.validate validationContext) animals
    addForms =
      Dict.union (formDict forms)
  in
    newModel
      |> model_animals.update addAnimals
      |> model_addPageAnimals.update addIds
      |> model_forms.update addForms

populateAllAnimalsPage : List Animal.Animal -> Model -> Model 
populateAllAnimalsPage animals model =
  { model
    | animals = displayedAnimalDict animals Animal.compact
    , allPageAnimals = List.map .id animals |> Set.fromList 
  }

displayedAnimalDict : List Animal.Animal -> (Animal.Animal -> Animal.DisplayedAnimal) -> Dict Animal.Id Animal.DisplayedAnimal
displayedAnimalDict animals displayedMaker =
  let
    ids =
      List.map .id animals
    displayedAnimals =
      List.map displayedMaker animals
  in
    List.map2 (,) ids displayedAnimals |> Dict.fromList

formDict : List Animal.Form -> Dict Animal.Id Animal.Form
formDict forms = 
  let
    ids = List.map .id forms
  in
    List.map2 (,) ids forms |> Dict.fromList
             

httpError contextString err model = 
  model_pageFlash.set (Page.HttpErrorFlash contextString err) model


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

