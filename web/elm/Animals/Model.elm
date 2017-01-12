module Animals.Model exposing (..)

import Animals.Msg exposing (..)

import Animals.Pages.H as Page
import Animals.Pages.Navigation as Page

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Animals.Animal.Lenses exposing (..)
import Animals.View.PageFlash as PageFlash exposing (PageFlash)

import Animals.OutsideWorld.Cmd as OutsideWorld

import Pile.Calendar exposing (EffectiveDate(..))
import Pile.UpdatingLens exposing (UpdatingLens, lens)

import Navigation
import Dict exposing (Dict)
import Set exposing (Set)
import Date exposing (Date)

type alias DisplayDict =
  Dict Id Displayed
    
type alias Model = 
  { page : Page.PageChoice
  , pageFlash : PageFlash
  , csrfToken : String
  , displayables : DisplayDict

  -- AllPage
  , allPageAnimals : Set Id
  , nameFilter : String
  , tagFilter : String
  , speciesFilter : String
  , effectiveDate : EffectiveDate
  , today : Maybe Date
  , datePickerOpen : Bool

  -- AddPage
  , addPageAnimals : Set Id
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
      , pageFlash = PageFlash.NoFlash
      , csrfToken = flags.csrfToken
      , displayables = Dict.empty

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


-- Todo: Figure out how to use lenses for this.      
upsertDisplayed : Displayed -> Model -> Model       
upsertDisplayed displayed model =
  let
    key = displayed_id.get displayed
    new = Dict.insert key displayed model.displayables
  in
    model_displayables.set new model

deleteDisplayed : Displayed -> Model -> Model
deleteDisplayed displayed model =
  deleteDisplayedById (displayed_id.get displayed) model
  
deleteDisplayedById : Id -> Model -> Model
deleteDisplayedById id model =
  model_displayables.update (Dict.remove id) model

deleteFromPage : UpdatingLens Model (Set Id) -> Id -> Model -> Model
deleteFromPage lens id = lens.update (Set.remove id)

upsertAnimal : Animal.Animal -> Model -> Model 
upsertAnimal animal =
  upsertDisplayed (Displayed.fromAnimal animal)
      
upsertForm : Form -> Model -> Model 
upsertForm form =
  upsertDisplayed (Displayed.fromForm form)
      

-- Boilerplate Lenses
      
model_page : UpdatingLens Model Page.PageChoice
model_page = lens .page (\ p w -> { w | page = p })

model_today : UpdatingLens Model (Maybe Date)
model_today = lens .today (\ p w -> { w | today = p })

model_displayables : UpdatingLens Model DisplayDict
model_displayables = lens .displayables (\ p w -> { w | displayables = p })

model_allPageAnimals : UpdatingLens Model (Set Id)
model_allPageAnimals = lens .allPageAnimals (\ p w -> { w | allPageAnimals = p })

model_addPageAnimals : UpdatingLens Model (Set Id)
model_addPageAnimals = lens .addPageAnimals (\ p w -> { w | addPageAnimals = p })

model_animalsEverAdded : UpdatingLens Model Int
model_animalsEverAdded = lens .animalsEverAdded (\ p w -> { w | animalsEverAdded = p })

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

model_pageFlash : UpdatingLens Model PageFlash
model_pageFlash = lens .pageFlash (\ p w -> { w | pageFlash = p })

