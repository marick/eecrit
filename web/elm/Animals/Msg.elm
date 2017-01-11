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

{-| A subtype of Msg. Always used as `WithAnimal <anAnimal> <submsg>` -}
type AnimalOperation
  = RemoveAnimalFlash
  | SwitchToReadOnly Animal.Format
  | StartEditing
  | MoreLikeThis

{-| A subtype of Msg. Always used as `WithForm <aForm> <submsg>` -}
type FormOperation
  = RemoveFormFlash
  | CancelEdits
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

  | WithAnimal Animal.Animal AnimalOperation
  | WithForm Animal.Form FormOperation
  | Page PageOperation
  | Incoming OutsideLeakageOperation 

  | SetToday (Maybe Date)
  | SetAnimals (List Animal)

  | ToggleDatePicker
  | SelectDate Date

  | SetNameFilter String
  | SetTagFilter String
  | SetSpeciesFilter String

  | AnimalGotSaved OutsideWorld.AnimalSaveResults
  | AnimalGotCreated OutsideWorld.AnimalCreationResults

  | AddNewAnimals Int String

