module Animals.Msg exposing (Msg(..))

import Animals.Pages.Declare exposing (PageChoice)
import Animals.Animal.Types as Animal exposing (Animal)
import Animals.Animal.Flash as Flash exposing (Flash)
import Date exposing (Date)
import Navigation
import Http

type Msg
  = NoticePageChange Navigation.Location
  | StartPageChange PageChoice

  | SetToday (Maybe Date)
  | SetAnimals (Result Http.Error (List Animal))

  | ToggleDatePicker
  | SelectDate Date

  | SetNameFilter String
  | SetTagFilter String
  | SetSpeciesFilter String

  | UpsertCompactAnimal Animal.Animal Flash
  | UpsertExpandedAnimal Animal.Animal Flash
  | UpsertEditableAnimal Animal.Animal Animal.Form Flash
    
  | StartSavingAnimalChanges Animal.DisplayedAnimal
  | AnimalSaveResults (Result Http.Error Int)

  | StartCreatingNewAnimal Animal.DisplayedAnimal
  | CancelAnimalChanges Animal.Animal Flash

  | AddNewBovine

  | MoreLikeThisAnimal Animal.Id


  | NoOp

