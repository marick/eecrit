module Animals.Main exposing (..)

import Animals.Msg exposing (..)
import Animals.OutsideWorld.Declare as OutsideWorld
import Animals.OutsideWorld.Define as OutsideWorld
import Animals.Animal.Types as Animal
import Animals.Animal.Constructors as Animal exposing (noFlash, andFlash)
import Animals.Animal.Lenses exposing (..)
-- import Animals.Animal.Aggregates as Aggregate
import Animals.Animal.Form as Form 
import Animals.Pages.Declare as Page
import Animals.Pages.Define as Page
import Animals.Pages.PageFlash as PageFlash
import Animals.Animal.Flash as AnimalFlash 
import Animals.Animal.Validation as Validation

import Pile.Bulma as Bulma exposing
  (FormStatus(..), FormValue, Urgency(..), Validity(..))
import Navigation
import String
import Set exposing (Set)
import List
import Dict exposing (Dict)
import Date exposing (Date)
import Pile.Calendar exposing (EffectiveDate(..))
import Pile.UpdatingLens exposing (lens)

-- Model and Init
type alias Flags =
  { csrfToken : String
  }

type alias Model = 
  { page : Page.PageChoice
  , pageFlash : PageFlash.Flash
  , csrfToken : String
  , animals : Dict Animal.Id Animal.DisplayedAnimal
  , forms : Dict Animal.Id Animal.Form

  -- AllPage
  , allPageAnimals : Set Animal.Id
  , nameFilter : String
  , tagFilter : String
  , speciesFilter : String
  , effectiveDate : EffectiveDate
  , today : Maybe Date
  , datePickerOpen : Bool

  -- AddPage
  , addPageAnimals : Set Animal.Id
  }

model_page = lens .page (\ p w -> { w | page = p })
model_today = lens .today (\ p w -> { w | today = p })
model_animals = lens .animals (\ p w -> { w | animals = p })
model_allPageAnimals = lens .allPageAnimals (\ p w -> { w | allPageAnimals = p })
model_addPageAnimals = lens .addPageAnimals (\ p w -> { w | addPageAnimals = p })
model_forms = lens .forms (\ p w -> { w | forms = p })
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
      , pageFlash = PageFlash.NoFlash
      , csrfToken = flags.csrfToken
      , animals = Dict.empty
      , forms = Dict.empty

      -- All Animals Page
      , allPageAnimals = Set.empty
      , nameFilter = ""
      , tagFilter = ""
      , speciesFilter = ""
      , effectiveDate = Today
      , today = Nothing
      , datePickerOpen = False

      -- Add Animals Page
      , addPageAnimals = Set.empty
      }
  in
    model ! [OutsideWorld.askTodaysDate, OutsideWorld.fetchAnimals]

-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  update_ msg (model_pageFlash.set PageFlash.NoFlash model)

update_ : Msg -> Model -> ( Model, Cmd Msg )
update_ msg model =
  case msg of
    NoticePageChange location ->
      model |> model_page.set (Page.fromLocation location) |> noCmd
      
    StartPageChange page ->
      ( model, Page.toPageChangeCmd page )
      
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

    CheckFormChange displayed changedForm ->
      let
        newAnimal = displayed |> noFlash
        newForm = checkForm newAnimal.animal changedForm model
      in
        model |> upsertAnimal newAnimal |> upsertForm newForm |> noCmd

    CancelAnimalCreation displayed form ->
      model |> noCmd
      -- let
      --   new = displayed |> noFlash |> displayedAnimal_format.set Animal.Expanded
      -- in
      --   model |> upsertAnimal new |> deleteFormFor displayed |> noCmd
          
    StartCreatingNewAnimal displayed form ->
      model |> noCmd
    --   ( recordAnimalManipulation model displayed
    --   , OutsideWorld.createAnimal displayed.animal
    --   )

    NoticeAnimalSaveResults (Ok (OutsideWorld.AnimalUpdated id version)) ->
      model |> lookupAndDo id (recordSuccessfulSave version) |> noCmd 

    -- TODO: Make this an animal flash instead of a page flash?
    -- More noticeable, but only works if there's just one animal being
    -- saved at a time. 
    NoticeAnimalSaveResults (Err e) ->
      model |> httpError "I could not save the animal." e |> noCmd

    NoticeAnimalCreationResults (Ok (OutsideWorld.AnimalCreated tempId realId)) ->
      model ! []
      -- let
      --   maybe = Dict.get (Debug.log "responsre" tempId) model.animals
      -- in
      --   case (Debug.log "fetched" maybe) of
      --       Nothing ->
      --         model ! [] -- impossible
      --       Just displayed ->
      --         ( displayed.animal
      --             |> Animal.expanded
      --             |> Animal.andFlash (displayed_flash.get displayed)
      --             |> recordAnimalManipulation model
      --         , Cmd.none
      --         )

    NoticeAnimalCreationResults (Err e) ->
      model |> httpError "I could not create the animal." e |> noCmd


    AddNewAnimals count species ->
      model ! []
      -- addNewAnimals count species model ! []

    WithAnimal displayed op ->
        applyAfterRemovingFlash (animalOp op) displayed model

    WithForm form op ->
      case Dict.get form.id model.animals of
        Nothing ->
          model |> noCmd -- Todo: a command to log the error
        Just displayed ->
          applyAfterRemovingFlash (formOp op form) displayed model 

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
    f displayed model
  
        
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
  case op of 
    CancelEdits ->
      let
        new = displayed |> displayedAnimal_format.set Animal.Expanded
      in
        model |> upsertAnimal new |> deleteForm form |> noCmd
    StartSavingEdits ->
      let
        newForm = form_status.set BeingSaved form
        valuesToSave = Form.updateAnimal form displayed.animal
      in
      ( model |> upsertForm newForm
      , OutsideWorld.saveAnimal valuesToSave
      )


-----------------------          


          
lookupAndDo id f model =
  let
    get field = model |> field |> Dict.get id
  in
    Maybe.map2 (f model) (get .animals) (get .forms)
      |> Maybe.withDefault model 
        
recordSuccessfulSave version model displayed form =
  let
    animal =
      displayed.animal |> Form.updateAnimal form |> animal_version.set version
    newDisplayed =
      { animal = animal
      , format = Animal.Expanded
      , animalFlash = Form.saveFlash form
      }
  in
    model |> upsertAnimal (Debug.log "newDisplayed" newDisplayed) |> deleteForm form
  

-- addNewAnimals count species model =
--   let
--     -- This is an enormous kludge due to need to generate unique ids, given
--     -- that I don't trust only 32 bits of non-collision.
--     -- It's also grossly inefficient.
--     addNext remainder modelSoFar =
--       if remainder == 0 then
--         modelSoFar
--       else
--         let
--           safeId = Aggregate.freshId modelSoFar.animals
--           animal = Animal.fresh species safeId
--           context = Validation.context modelSoFar.animals animal
--           form = Form.extractForm animal |> Validation.validate context
--         in
--           Animal.empty animal (Debug.log "form" form)
--             |> recordAnimalManipulation modelSoFar
--             |> addNext (remainder - 1)
--   in
--     addNext count model
        
checkForm animal form model =
  Validation.validate (Validation.context model.animals animal) form 

-- deleteDisplayedAnimalById model id  =
--   model_animals.update (Aggregate.deleteById id) model

setFormat = displayedAnimal_format.set


populateAllAnimalsPage : List Animal.Animal -> Model -> Model 
populateAllAnimalsPage animals model =
  let
    ids =
      List.map .id animals
    displayedAnimals =
      List.map Animal.compact animals
  in
    { model
      | animals = List.map2 (,) ids displayedAnimals |> Dict.fromList
      ,  allPageAnimals = Set.fromList ids
    }

httpError contextString err model = 
  model_pageFlash.set (PageFlash.HttpErrorFlash contextString err) model

noCmd model = model ! []

upsertAnimal : Animal.DisplayedAnimal -> Model -> Model 
upsertAnimal displayedAnimal model =
  let
    key = displayedAnimal_id.get displayedAnimal
    newAnimals = Dict.insert key displayedAnimal model.animals
  in
    model_animals.set newAnimals model

upsertForm : Animal.Form -> Model -> Model 
upsertForm form model =
  let
    key = form_id.get form
    newForms = Dict.insert key form model.forms
  in
    model_forms.set newForms model

deleteForm : Animal.Form -> Model -> Model
deleteForm form model =
  let
    key = form_id.get form
  in
    model_forms.update (Dict.remove key) model
  

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
