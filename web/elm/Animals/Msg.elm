module Animals.Msg exposing (..)

import Animals.Pages.Declare exposing (PageChoice)
import Animals.OutsideWorld.Declare as OutsideWorld
import Animals.Animal.Types as Animal exposing (Animal)
import Date exposing (Date)
import Navigation
import Http

-- A subtype of Msg. Always used as `WithAnimal <displayedAnimal> <submsg>`
type AnimalOperation
  = RemoveFlash
  | SwitchToReadOnly Animal.Format
  | StartEditing
  | MoreLikeThis

type FormOperation
  = CancelEdits
  | StartSavingEdits

  | CancelCreation
  | StartCreating
    
  | NameFieldUpdate String
  | TentativeTagUpdate String
  | CreateNewTag
  | DeleteTag String 


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

  | NoticeAnimalSaveResults (Result Http.Error OutsideWorld.AnimalSaveResults)
  | NoticeAnimalCreationResults (Result Http.Error OutsideWorld.AnimalCreationResults)

  | AddNewAnimals Int String

  | WithAnimal Animal.DisplayedAnimal AnimalOperation
  | WithForm Animal.Form FormOperation
  | NoOp

