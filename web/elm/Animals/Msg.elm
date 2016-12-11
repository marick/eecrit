module Animals.Msg exposing (Msg(..))

import Animals.Animal.Model as Animal exposing (Animal)
import Animals.Animal.Flash as Flash exposing (Flash)
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
  | UpsertCompactAnimal Animal.Animal Flash
  | UpsertExpandedAnimal Animal.Animal Flash
  | UpsertEditableAnimal Animal.Animal Animal.Form Flash

  | MoreLikeThisAnimal Animal.Id

  | NoOp

