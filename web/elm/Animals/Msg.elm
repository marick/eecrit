module Animals.Msg exposing (Msg(..))

import Animals.Pages.Declare exposing (PageChoice)
import Animals.OutsideWorld.Declare as OutsideWorld
import Animals.Animal.Types as Animal exposing (Animal)
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

  | BeginCompactAnimalView Animal.Animal 
  | BeginExpandedAnimalView Animal.Animal 
  | BeginEditing Animal.Animal 
  | CheckFormChange Animal.Animal Animal.Form 
    
  | StartSavingAnimalChanges Animal.DisplayedAnimal
  | NoticeAnimalSaveResults (Result Http.Error OutsideWorld.AnimalSaveResults)

  | StartCreatingNewAnimal Animal.DisplayedAnimal
  | NoticeAnimalCreationResults (Result Http.Error OutsideWorld.AnimalCreationResults)
  | CancelAnimalChanges Animal.Animal 

  | AddNewAnimals Int String

  | MoreLikeThisAnimal Animal.Id

  | RemoveFlash Animal.DisplayedAnimal

  | NoOp

