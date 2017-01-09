module Animals.Model exposing (..)

import Animals.Msg exposing (..)

import Animals.Pages.H as Page
import Animals.Pages.PageFlash as Page
import Animals.Pages.Navigation as Page

import Animals.Animal.Types as Animal
import Animals.Animal.Lenses exposing (..)

import Animals.OutsideWorld.Cmd as OutsideWorld

import Pile.Calendar exposing (EffectiveDate(..))
import Pile.UpdatingLens exposing (UpdatingLens, lens)

import Navigation
import Dict exposing (Dict)
import Set exposing (Set)
import Date exposing (Date)

type alias DisplayDict =
  Dict Animal.Id Animal.DisplayedAnimal

type alias FormDict =     
  Dict Animal.Id Animal.Form

type alias IdSet = 
  Set Animal.Id
    
type alias Model = 
  { page : Page.PageChoice
  , pageFlash : Page.Flash
  , csrfToken : String
  , animals : DisplayDict
  , displayed : Dict Animal.Id Animal.Displayed
  , forms : FormDict

  -- AllPage
  , allPageAnimals : IdSet
  , nameFilter : String
  , tagFilter : String
  , speciesFilter : String
  , effectiveDate : EffectiveDate
  , today : Maybe Date
  , datePickerOpen : Bool

  -- AddPage
  , addPageAnimals : IdSet
  , animalsEverAdded : Int -- This is dumb, but probably easiest way to add a
                           --  a guaranteed-unique id in the absence of reliable
                           --  UUIDs. (I don't trust only 32 bits, which is paranoid.)
  }

type alias Flags =
  { csrfToken : String
  }

init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
  let
    model =
      { page = Page.fromLocation(location)
      , pageFlash = Page.NoFlash
      , csrfToken = flags.csrfToken
      , animals = Dict.empty
      , forms = Dict.empty
      , displayed = Dict.empty

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
      , animalsEverAdded = 0
      }
  in
    model ! [OutsideWorld.askTodaysDate, OutsideWorld.fetchAnimals]


      
upsertForm : Animal.Form -> Model -> Model 
upsertForm form model =
  let
    key = form_id.get form
    newForms = Dict.insert key form model.forms
  in
    model_forms.set newForms model

upsertAnimal : Animal.DisplayedAnimal -> Model -> Model 
upsertAnimal displayed model =
  let
    key = displayedAnimal_id.get displayed
    newAnimals = Dict.insert key displayed model.animals
  in
    model_animals.set newAnimals model
deleteAnimal : Animal.DisplayedAnimal -> Model -> Model
deleteAnimal displayed model =
  deleteAnimalById (displayedAnimal_id.get displayed) model
  
deleteAnimalById : Animal.Id -> Model -> Model
deleteAnimalById id model =
  model_animals.update (Dict.remove id) model
  
deleteForm : Animal.Form -> Model -> Model
deleteForm form model =
  deleteFormById (form_id.get form) model

deleteFormById : Animal.Id -> Model -> Model
deleteFormById id model =
    model_forms.update (Dict.remove id) model

-- Boilerplate Lenses
      
model_page : UpdatingLens Model Page.PageChoice
model_page = lens .page (\ p w -> { w | page = p })

model_today : UpdatingLens Model (Maybe Date)
model_today = lens .today (\ p w -> { w | today = p })

model_animals : UpdatingLens Model DisplayDict
model_animals = lens .animals (\ p w -> { w | animals = p })

model_allPageAnimals : UpdatingLens Model IdSet
model_allPageAnimals = lens .allPageAnimals (\ p w -> { w | allPageAnimals = p })

model_addPageAnimals : UpdatingLens Model IdSet
model_addPageAnimals = lens .addPageAnimals (\ p w -> { w | addPageAnimals = p })

model_animalsEverAdded : UpdatingLens Model Int
model_animalsEverAdded = lens .animalsEverAdded (\ p w -> { w | animalsEverAdded = p })

model_forms : UpdatingLens Model FormDict
model_forms = lens .forms (\ p w -> { w | forms = p })

model_tagFilter : UpdatingLens Model String
model_tagFilter = lens .tagFilter (\ p w -> { w | tagFilter = p })

model_speciesFilter : UpdatingLens Model String
model_speciesFilter = lens .speciesFilter (\ p w -> { w | speciesFilter = p })

model_nameFilter : UpdatingLens Model String
model_nameFilter = lens .nameFilter (\ p w -> { w | nameFilter = p })

model_effectiveDate : UpdatingLens Model EffectiveDate
model_effectiveDate = lens .effectiveDate (\ p w -> { w | effectiveDate = p })

model_datePickerOpen : UpdatingLens Model Bool
model_datePickerOpen = lens .datePickerOpen (\ p w -> { w | datePickerOpen = p })

model_pageFlash : UpdatingLens Model Page.Flash
model_pageFlash = lens .pageFlash (\ p w -> { w | pageFlash = p })

