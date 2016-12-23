module Animals.Main exposing (..)

import Animals.Msg exposing (..)
import Animals.OutsideWorld.Declare as OutsideWorld
import Animals.OutsideWorld.Define as OutsideWorld
import Animals.Animal.Types as Animal
import Animals.Animal.Constructors as Animal
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Aggregates as Aggregate
import Animals.Animal.Form as Form
import Animals.Pages.Declare as Page
import Animals.Pages.Define as Page
import Animals.Pages.PageFlash as PageFlash
import Animals.Animal.Flash as AnimalFlash
import Animals.Animal.Validation as Validation

import Pile.Bulma exposing (FormValue, Urgency(..), Validity(..))
import Navigation
import String
import Set
import List
import Dict
import Date exposing (Date)
import Pile.Calendar exposing (EffectiveDate(..))
import Pile.UpdatingLens exposing (lens)

-- Model and Init
type alias Flags =
  { csrfToken : String
  }

type alias Model = 
  { page : Page.PageChoice
  , csrfToken : String
  , animals : Aggregate.VisibleAggregate

  -- AllPage
  , nameFilter : String
  , tagFilter : String
  , speciesFilter : String
  , effectiveDate : EffectiveDate
  , today : Maybe Date
  , datePickerOpen : Bool

  -- AddPage
  , pageFlash : PageFlash.Flash
  }

model_page = lens .page (\ p w -> { w | page = p })
model_today = lens .today (\ p w -> { w | today = p })
model_animals = lens .animals (\ p w -> { w | animals = p })
model_tagFilter = lens .tagFilter (\ p w -> { w | tagFilter = p })
model_speciesFilter = lens .speciesFilter (\ p w -> { w | speciesFilter = p })
model_nameFilter = lens .nameFilter (\ p w -> { w | nameFilter = p })
model_effectiveDate = lens .effectiveDate (\ p w -> { w | effectiveDate = p })
model_datePickerOpen = lens .datePickerOpen (\ p w -> { w | datePickerOpen = p })
model_pageFlash = lens .pageFlash (\ p w -> { w | pageFlash = p })



init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
  let
    model =
      { page = Page.fromLocation(location)
      , csrfToken = flags.csrfToken
      , animals = Aggregate.emptyAggregate
      , nameFilter = ""
      , tagFilter = ""
      , speciesFilter = ""
      , effectiveDate = Today
      , today = Nothing
      , datePickerOpen = False
      , pageFlash = PageFlash.NoFlash
      }
  in
    model ! [OutsideWorld.askTodaysDate, OutsideWorld.fetchAnimals]

-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  update_ msg (model_pageFlash.set PageFlash.NoFlash model)

update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ msg model =
  case Debug.log "update" msg of
    NoticePageChange location -> 
      model_page.set (Page.fromLocation location) model ! []
    StartPageChange page ->
      ( model, Page.toPageChangeCmd page )
      
    SetToday value ->
      model_today.set value model ! []
    SetAnimals (Ok animals) ->
      model_animals.set (Aggregate.asAggregate animals) model ! []
    SetAnimals (Err e) ->
      httpError "I could not retrieve animals." e model ! []

    ToggleDatePicker ->
      model_datePickerOpen.update not model ! []
    SelectDate date ->
      model_effectiveDate.set (At date) model ! []
      
    SetNameFilter s ->
      model_nameFilter.set s model ! []
    SetTagFilter s ->
      model_tagFilter.set s model ! []
    SetSpeciesFilter s ->
      model_speciesFilter.set s model ! []

    MoreLikeThisAnimal id ->
      ( model 
      , Cmd.none
      )

    EnsureCompactAnimalView animal ->
      (Animal.compact animal |> upsertDisplayedAnimal model) ! []
          
    EnsureExpandedAnimalView animal ->
      (Animal.expanded animal |> upsertDisplayedAnimal model) ! []

    BeginEditing animal ->
      let
        form = (Form.extractForm animal)
      in
        (Animal.editable animal form |> upsertDisplayedAnimal model) ! []

    CheckFormChange animal changedForm ->
      let
        form = checkForm animal changedForm model
      in
        (Animal.editable animal form |> upsertDisplayedAnimal model) ! []

    StartSavingAnimalChanges displayedAnimal ->
      ( upsertDisplayedAnimal model displayedAnimal
      , OutsideWorld.saveAnimal displayedAnimal.animal
      )

    NoticeAnimalSaveResults (Ok (OutsideWorld.AnimalUpdated id version)) ->
      let
        savedAnimalMaybe = Dict.get id model.animals
      in
        case savedAnimalMaybe of
            Nothing ->
              model ! [] -- impossible
            Just displayedAnimal ->
              ( displayedAnimal.animal
                  |> animal_version.set version
                  |> Animal.expanded
                  |> Animal.andFlash (displayedAnimal_flash.get displayedAnimal)
                  |> upsertDisplayedAnimal model
              , Cmd.none
              )

    NoticeAnimalSaveResults (Err e) ->
      httpError "I could not save the animal." e model ! []

    StartCreatingNewAnimal displayedAnimal ->
      tmp_start_creating displayedAnimal model ! []

    CancelAnimalChanges animal ->
      case animal.wasEverSaved of
        True -> 
          (Animal.expanded animal |> upsertDisplayedAnimal model) ! []
        False ->
          deleteDisplayedAnimalById model animal.id ! [] 

    AddNewBovine ->
      (Form.freshEditableAnimal (Aggregate.freshId model.animals) |> upsertDisplayedAnimal model) ! []

    RemoveFlash displayedAnimal ->
      (displayedAnimal_flash.set AnimalFlash.NoFlash displayedAnimal |> upsertDisplayedAnimal model) ! []
        
    NoOp ->
      model ! []

checkForm animal form model =
  Validation.validate form (Validation.context model.animals animal)
           
upsertDisplayedAnimal model displayed =
  model_animals.update (Aggregate.upsert displayed) model

deleteDisplayedAnimalById model id  =
  model_animals.update (Aggregate.deleteById id) model

tmp_start_creating {animal, display} model =
  let
    animalToSave = animal_wasEverSaved.set True animal
    modelToSave = model_pageFlash.set PageFlash.SavedAnimalFlash model
  in
    Animal.expanded animalToSave |> upsertDisplayedAnimal modelToSave

httpError contextString err model = 
  model_pageFlash.set (PageFlash.HttpErrorFlash contextString err) model
  
-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
