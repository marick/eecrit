module Animals.Main exposing (..)

import Animals.Types exposing (..)
import Animals.OutsideWorld as OutsideWorld
import Animals.Navigation as MyNav

import Navigation
import String
import List
import Date exposing (Date)
import Date.Extra
import Task
import Dict exposing (Dict)
import Pile.Calendar exposing (EffectiveDate(..))

-- Model and Init
type alias Flags =
  { csrfToken : String
  }

type alias Model = 
  { page : MyNav.PageChoice
  , csrfToken : String
  , animals : List Animal
  , nameFilter : String
  , tagFilter : String
  , speciesFilter : String
  , effectiveDate : EffectiveDate
  , today : Maybe Date
  , datePickerOpen : Bool
  }



askTodaysDate =
  Task.perform (always (SetToday Nothing)) (Just >> SetToday) Date.now
  
init : Flags -> MyNav.PageChoice -> ( Model, Cmd Msg )
init flags startingPage =
  ( { page = startingPage
    , csrfToken = flags.csrfToken
    , animals = OutsideWorld.fetchAnimals
    , nameFilter = ""
    , tagFilter = ""
    , speciesFilter = ""
    , effectiveDate = Today
    , today = Nothing
    , datePickerOpen = False
    }
  , askTodaysDate
  )


filteredAnimals model = 
  let
    hasWanted modelFilter animalValue =
      let 
        wanted = model |> modelFilter |> String.toLower
        has = animalValue |> String.toLower
      in
        String.startsWith wanted has

    hasDesiredSpecies animal = hasWanted .speciesFilter animal.species
    hasDesiredName animal = hasWanted .nameFilter animal.name
    hasDesiredTag animal =
      List.any (hasWanted .tagFilter) animal.tags

  in
    model.animals
      |> List.filter hasDesiredSpecies
      |> List.filter hasDesiredName
      |> List.filter hasDesiredTag
      |> List.sortBy (.name >> String.toLower)
      
-- Msg

type alias Id = String

type Msg
  = NavigateToAllPage
  | NavigateToSpreadsheetPage
  | NavigateToSummaryPage
  | NavigateToAddPage
  | NavigateToHelpPage

  | SetToday (Maybe Date)
  | ToggleDatePicker
  | SelectDate Date

  | ExpandAnimal Id
  | ContractAnimal Id
  | EditAnimal Id
  | SetEditedName Id String
  | CancelAnimalEdit Id
  | SaveAnimalEdit Id

  | MoreLikeThisAnimal Id

  | SetNameFilter String
  | SetTagFilter String
  | SetSpeciesFilter String

  | NoOp

-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      ( model, Cmd.none )
    NavigateToAllPage ->
      goto model MyNav.allPagePath
    NavigateToSpreadsheetPage ->
      goto model MyNav.spreadsheetPagePath
    NavigateToSummaryPage ->
      goto model MyNav.summaryPagePath
    NavigateToAddPage ->
      goto model MyNav.addPagePath
    NavigateToHelpPage ->
      goto model MyNav.helpPagePath

    SetToday value ->
      ( { model | today = value }
      , Cmd.none
      )
    ToggleDatePicker ->
      ( { model | datePickerOpen = not model.datePickerOpen }
      , Cmd.none
      )
    SelectDate date ->
      ( { model | effectiveDate = At date }
      , Cmd.none
      )
      
    MoreLikeThisAnimal id ->
      ( model 
      , Cmd.none
      )

    ExpandAnimal id ->
      ( { model | animals = transformAnimal (toState Expanded) id model.animals }
      , Cmd.none
      )
    ContractAnimal id ->
      ( { model | animals = transformAnimal (toState Compact) id model.animals }
      , Cmd.none
      )
    EditAnimal id ->
      ( { model | animals =
            transformAnimal (toState Editable >> makeEditableCopy) id model.animals
        }
      , Cmd.none
      )

    SetEditedName id name ->
      ( { model | animals =
            transformAnimal (setEditedName name) id model.animals }
      , Cmd.none
      )

    CancelAnimalEdit id ->
      ( { model | animals =
            transformAnimal (toState Expanded >> cancelEditableCopy) id model.animals
        }
      , Cmd.none )

    SaveAnimalEdit id ->
      ( { model | animals =
            transformAnimal (toState Expanded >> replaceEditableCopy) id model.animals
        }
      , Cmd.none )

    SetNameFilter s ->
      ( { model | nameFilter = s }
      , Cmd.none
      )
    SetTagFilter s ->
      ( { model | tagFilter = s }
      , Cmd.none
      )
    SetSpeciesFilter s ->
      ( { model | speciesFilter = s }
      , Cmd.none
      )

toState newState animal =
  { animal | displayState = newState }

setEditedName newName animal =
  let
    setter editableCopy = { editableCopy | name = newName }
  in
    { animal | editableCopy = Maybe.map setter animal.editableCopy }

makeEditableCopy animal =
  let
    extracted =
      { name = animal.name
      , tags = animal.tags
      }
  in
    { animal | editableCopy = Just extracted }


-- TODO: Lack of valid editable copy should make Save unclickable.
      
replaceEditableCopy animal =
  case animal.editableCopy of
    Nothing -> -- impossible
      animal
    (Just newValues) -> 
      { animal
        | name = newValues.name
        , tags = newValues.tags
          
        , editableCopy = Nothing
      }
  
cancelEditableCopy animal = 
  { animal | editableCopy = Nothing }
      
transformAnimal transformer id animals =
  let
    doOne animal =
      if animal.id == id then
        transformer animal
      else
        animal
  in
    List.map doOne animals

      
goto : Model -> String -> (Model, Cmd Msg)        
goto model path =
  ( model
  , Navigation.newUrl path
  )

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
