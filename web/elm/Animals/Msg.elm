module Animals.Msg exposing (Msg(..))

import Animals.Pages.Declare exposing (PageChoice)
import Animals.OutsideWorld.Declare as OutsideWorld
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

  | EnsureCompactAnimalView Animal.Animal Flash
  | EnsureExpandedAnimalView Animal.Animal Flash
  | BeginEditing Animal.Animal Flash
  | CheckFormChange Animal.Animal Animal.Form Flash
    
  | StartSavingAnimalChanges Animal.DisplayedAnimal
  | NoticeAnimalSaveResults (Result Http.Error OutsideWorld.AnimalSaveResults)

  | StartCreatingNewAnimal Animal.DisplayedAnimal
  | CancelAnimalChanges Animal.Animal Flash

  | AddNewBovine

  | MoreLikeThisAnimal Animal.Id


  | NoOp

