module Animals.Msg exposing (Id, Msg(..))

import Animals.Types exposing (..)
import Date exposing (Date)

type alias Id = String

type Msg
  = NavigateToAllPage
  | NavigateToAddPage
  | NavigateToHelpPage

  | SetToday (Maybe Date)
  | SetAnimals (List PersistentAnimal)

  | ToggleDatePicker
  | SelectDate Date

  | SetNameFilter String
  | SetTagFilter String
  | SetSpeciesFilter String

  | ReviseDisplayedAnimal Id DisplayedAnimal

  | SetEditedName Id String
  | DeleteTagWithName Id String
  | SetTentativeTag Id String
  | CreateNewTag Id
  | CancelAnimalEdit Id
  | SaveAnimalEdit Id

  | MoreLikeThisAnimal Id

  | NoOp

