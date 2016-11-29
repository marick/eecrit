module Animals.Main exposing (..)

import Navigation
import Animals.Navigation as MyNav
import String
import List
import Date
import Task
import Pile.Calendar exposing (EffectiveDate(..))

-- Model and Init

type alias Flags =
  { csrfToken : String
  }

type DisplayState
  = Compact
  | Expanded
  | Editable

type alias Animal =
  { id : String
  , name : String
  , species : String
  , tags : List String
  , dateAcquired : String
  , dateRemoved : Maybe String
  , displayState : DisplayState
  }
       
type alias Model = 
  { page : MyNav.PageChoice
  , csrfToken : String
  , animals : List Animal
  , nameFilter : String
  , tagFilter : String
  , speciesFilter : String
  , effectiveDate : EffectiveDate
  , today : Maybe Date.Date
  , datePickerOpen : Bool
  }


athena =
  { id = "1"
  , name = "Athena"
  , species = "bovine"
  , tags = [ "cow" ]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
  , displayState = Compact
  }

jake =
  { id = "2"
  , name = "Jake"
  , species = "equine"
  , tags = [ "gelding" ]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
  , displayState = Compact
  }

ross =
  { id = "3"
  , name = "ross"
  , species = "equine"
  , tags = [ "stallion", "aggressive"]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
  , displayState = Compact
  }

xena =
  { id = "4"
  , name = "Xena"
  , species = "equine"
  , tags = [ "mare", "skittish" ]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
  , displayState = Compact
  }

askTodaysDate =
  Task.perform (always (SetToday Nothing)) (Just >> SetToday) Date.now
  
init : Flags -> MyNav.PageChoice -> ( Model, Cmd Msg )
init flags startingPage =
  ( { page = startingPage
    , csrfToken = flags.csrfToken
    , animals = [athena, jake, xena, ross]
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
  | NavigateToAddPage
  | NavigateToHelpPage

  | SetToday (Maybe Date.Date)
  | ToggleDatePicker
  | SelectDate Date.Date

  | ExpandAnimal Id
  | ContractAnimal Id
  | EditAnimal Id
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
      ( { model | effectiveDate = At (Debug.log "set date" date) }
      , Cmd.none
      )
      
    ExpandAnimal id ->
      ( { model | animals = toState Expanded id model.animals }
      , Cmd.none
      )
    ContractAnimal id ->
      ( { model | animals = toState Compact id model.animals }
      , Cmd.none
      )
    EditAnimal id ->
      ( model
      , Cmd.none
      )
    MoreLikeThisAnimal id ->
      ( model 
      , Cmd.none
      )
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

transformAnimal pred transformer animal =
  if pred animal then
    transformer animal
  else
    animal
      
toState newState id animals =
  List.map
    (transformAnimal (\ a -> a.id == id)
       (\ a -> { a | displayState = newState }))
    animals

      
goto : Model -> String -> (Model, Cmd Msg)        
goto model path =
  ( model
  , Navigation.newUrl path
  )

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
