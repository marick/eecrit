module Animals.Msg exposing (..)

import Animals.Pages.H exposing (PageChoice)
import Animals.OutsideWorld.H as OutsideWorld
import Animals.Animal.Types as Animal exposing (Animal)
import Date exposing (Date)
import Navigation
import Http

{-| A subtype of Msg. Always used as `Page <submsg>` -}
type PageOperation
  = NoticeChange Navigation.Location
  | StartChange PageChoice

{-| Outside operation leakage -}
type OutsideLeakageOperation
  = HttpError String Http.Error

{-| A subtype of Msg. Always used as `WithAnimal <aDisplayedAnimal> <submsg>` -}
type AnimalOperation
  = RemoveFlash
  | SwitchToReadOnly Animal.Format
  | StartEditing
  | MoreLikeThis

{-| A subtype of Msg. Always used as `WithForm <aForm> <submsg>` -}
type FormOperation
  = CancelEdits
  | StartSavingEdits
  | NoticeSaveResults
  | NoticeCreationResults Animal.Id

  | CancelCreation
  | StartCreating
    
  | NameFieldUpdate String
  | TentativeTagUpdate String
  | CreateNewTag
  | DeleteTag String 


type Msg
  = NoOp

  | WithAnimal Animal.DisplayedAnimal AnimalOperation
  | WithForm Animal.Form FormOperation
  | Page PageOperation
  | Incoming OutsideLeakageOperation 

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

