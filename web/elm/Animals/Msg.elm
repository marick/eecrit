module Animals.Msg exposing (Msg(..))

import Animals.Animal.Model as Animal exposing (Animal)
import Date exposing (Date)

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

  | MoreLikeThisAnimal Animal.Id

  | NoOp

