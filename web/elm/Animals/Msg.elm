module Animals.Msg exposing (Msg(..))

import Animals.Animal.Types as Animal exposing (Animal)
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

  | UpsertCompactAnimal Animal.Animal Flash
  | UpsertExpandedAnimal Animal.Animal Flash
  | UpsertEditableAnimal Animal.Animal Animal.Form Flash

  | MoreLikeThisAnimal Animal.Id

  | NoOp

