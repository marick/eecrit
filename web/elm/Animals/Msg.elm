module Animals.Msg exposing (Id, Msg(..))

import Animals.Animal.Model as Animal exposing (Animal)
import Date exposing (Date)

type alias Id = String

type Msg
  = NavigateToAllPage
  | NavigateToAddPage
  | NavigateToHelpPage

  | SetToday (Maybe Date)
  | SetAnimals (List Animal)

  | ToggleDatePicker
  | SelectDate Date

  | SetNameFilter String
  | SetTagFilter String
  | SetSpeciesFilter String

  | ReviseDisplayedAnimal Animal.DisplayedAnimal

  | MoreLikeThisAnimal Id

  | NoOp

