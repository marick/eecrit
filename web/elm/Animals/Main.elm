module Animals.Main exposing (..)

import Animals.Animal as Animal
import Animals.Lenses exposing (..)
import Animals.Msg exposing (..)
import Animals.OutsideWorld as OutsideWorld
import Animals.Navigation as MyNav
import Animals.Types exposing (..)

import String
import List
import Date exposing (Date)
import Dict exposing (Dict)
import Pile.Calendar exposing (EffectiveDate(..))
import Return


-- Model and Init
type alias Flags =
  { csrfToken : String
  }

type alias Model = 
  { page : MyNav.PageChoice
  , csrfToken : String
  , animals : Dict Id DisplayedAnimal
  , nameFilter : String
  , tagFilter : String
  , speciesFilter : String
  , effectiveDate : EffectiveDate
  , today : Maybe Date
  , datePickerOpen : Bool
  }



init : Flags -> MyNav.PageChoice -> ( Model, Cmd Msg )
init flags startingPage =
  let
    model =
      { page = startingPage
      , csrfToken = flags.csrfToken
      , animals = Dict.empty
      , nameFilter = ""
      , tagFilter = ""
      , speciesFilter = ""
      , effectiveDate = Today
      , today = Nothing
      , datePickerOpen = False
      }
  in
    model ! [OutsideWorld.askTodaysDate, OutsideWorld.fetchAnimals]

-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NavigateToAllPage ->
      MyNav.toAllPagePath model
    NavigateToSpreadsheetPage ->
      MyNav.toSpreadsheetPagePath model
    NavigateToSummaryPage ->
      MyNav.toSummaryPagePath model
    NavigateToAddPage ->
      MyNav.toAddPagePath model
    NavigateToHelpPage ->
      MyNav.toHelpPagePath model

    SetToday value ->
      model_today.set value model ! []
    SetAnimals animals ->
      model_animals.set (Animal.asDict animals) model ! []

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

    NoOp ->
      model ! []
      

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
