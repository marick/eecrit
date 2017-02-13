module Animals.Model exposing (..)

import Animals.Msg exposing (..)

import Animals.Pages.H as Page
import Animals.Pages.Navigation as Page

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.AnimalHistory as AnimalHistory exposing (History)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Animals.Types.DisplayedCollections as Displayable
import Animals.Types.Conversions as Convert 
import Animals.Types.Lenses exposing (..)
import Animals.View.PageFlash as PageFlash exposing (PageFlash)

import Animals.OutsideWorld.Cmd as OutsideWorld

import Pile.Calendar as Calendar 
import Pile.DateHolder as DateHolder exposing (DateHolder, DisplayDate(..))
import Pile.UpdatingLens as Lens exposing (UpdatingLens, lens)
import Pile.UpdatingOptional as Optional exposing (UpdatingOptional, opt)
import Pile.Namelike exposing (Namelike)
import Pile.Css.H as Css

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
  , effectiveDate : DateHolder

  -- AddPage
  , addPageAnimals : Set Id
  , speciesToAdd : Namelike
  , numberToAdd : Css.FormValue String
  , animalsEverAdded : Int -- This is dumb, but probably easiest way to add a
                           --  a guaranteed-unique id in the absence of reliable
                           --  UUIDs. (I don't trust only 32 bits, which is paranoid.)
  -- HistoryPages
  , historyPages : Dict Id History
  , historyOrder : List Id
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
      , effectiveDate = DateHolder.startingState

      -- Add Animals Page
      , addPageAnimals = Set.empty
      , speciesToAdd = "bovine"
      , numberToAdd = Css.freshValue "1"
      , animalsEverAdded = 0

      -- History Pages
      , historyPages = Dict.empty
      , historyOrder = []
      }
  in
    ( model,  OutsideWorld.askTodaysDate ) -- Nothing starts until we have a date

-- Ways of tweaking bits of this      

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


-- Todo: Figure out how to use lenses for this.

getDisplayed : Id -> Model -> Maybe Displayed
getDisplayed id model =
  Dict.get id model.displayables

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
  upsertDisplayed (Convert.animalToDisplayed animal)
      
upsertCheckedForm : Form -> Model -> Model 
upsertCheckedForm form =
  upsertDisplayed (Convert.checkedFormToDisplayed form)

upsertHistoryPage : Id -> History -> Model -> Model
upsertHistoryPage id history =
  model_historyPages.update (Dict.insert id history)

placeHistoryInOrder : Id -> Model -> Model
placeHistoryInOrder id =
  model_historyOrder.update (\order -> id :: order)


-- Boilerplate Lenses
      
model_page : UpdatingLens Model Page.PageChoice
model_page = lens .page (\ p w -> { w | page = p })

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

model_effectiveDate : UpdatingLens Model DateHolder
model_effectiveDate = lens .effectiveDate (\ p w -> { w | effectiveDate = p })

model_datePickerState : UpdatingLens Model DateHolder.DatePickerState
model_datePickerState = Lens.compose model_effectiveDate DateHolder.dateHolder_pickerState

model_effectiveDate_chosen : UpdatingLens Model DisplayDate
model_effectiveDate_chosen = Lens.compose model_effectiveDate DateHolder.dateHolder_chosen

model_today : UpdatingOptional Model Date
model_today =
  Optional.compose
    (Optional.fromLens model_effectiveDate)
    DateHolder.dateHolder_todayForReference

model_pageFlash : UpdatingLens Model PageFlash
model_pageFlash = lens .pageFlash (\ p w -> { w | pageFlash = p })

model_speciesToAdd : UpdatingLens Model String
model_speciesToAdd = lens .speciesToAdd (\ p w -> { w | speciesToAdd = p })

model_numberToAdd : UpdatingLens Model (Css.FormValue String)
model_numberToAdd = lens .numberToAdd (\ p w -> { w | numberToAdd = p })

model_historyPages : UpdatingLens Model (Dict Id History)
model_historyPages = lens .historyPages (\ p w -> { w | historyPages = p })

model_historyOrder : UpdatingLens Model (List Id)
model_historyOrder = lens .historyOrder (\ p w -> { w | historyOrder = p })
                                          
