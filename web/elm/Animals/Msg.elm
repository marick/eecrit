module Animals.Msg exposing (..)

import Animals.Pages.H exposing (PageChoice)
import Animals.OutsideWorld.H as OutsideWorld
import Animals.Types.Basic exposing (..)
import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.AnimalHistory as AnimalHistory
import Date exposing (Date)
import Navigation
import Pile.Namelike exposing (Namelike)
import Http

{-| A subtype of Msg. Always used as `Page <submsg>` -}
type NavigationOperation
  = NoticeChange Navigation.Location
  | StartChange PageChoice

type AllPageOperation
  = OpenDatePicker
  | CalendarClick Date
  | SaveCalendarDate
  | DiscardCalendarDate 

  | SetAnimals (List Animal)

  | SetNameFilter String
  | SetTagFilter String
  | SetSpeciesFilter String

type AddPageOperation
  = SetAddedSpecies Namelike
  | UpdateAddedCount String
  | AddFormsForBlankTemplate Int Namelike

type HistoryPageOperation
  = SetHistory (List AnimalHistory.Entry)
  | CloseHistoryPage

{-| Outside operation leakage -}
type OutsideLeakageOperation
  = HttpError String Http.Error

{-| A subtype of Msg. Always used as `WithAnimal <anAnimal> <submsg>` -}
type AnimalOperation
  = RemoveAnimalFlash
  | SwitchToReadOnly Animal.Format
  | StartEditing

{-| A subtype of Msg. Always used as `WithForm <aForm> <submsg>` -}
type FormOperation
  = RemoveFormFlash
  | CancelEdits
  | StartSavingEdits
  | NoticeSaveResults
  | NoticeCreationResults Id

  | CancelCreation
  | StartCreating
    
  | NameFieldUpdate String
  | TentativeTagUpdate String
  | CreateNewTag
  | DeleteTag String
  | ToggleFormDatePicker
  | SelectFormDate Date

{-| A subtype of Msg. Always used as `WithDisplayedId <Id> <submsg>` -}
type DisplayedOperation
  = BeginGatheringCopyInfo
  | UpdateCopyCount String
  | AddFormsBasedOnAnimal Int

type Msg
  = NoOp

  | Navigate NavigationOperation
  | Incoming OutsideLeakageOperation 
  | OnAllPage AllPageOperation
  | OnAddPage AddPageOperation
  | OnHistoryPage Id HistoryPageOperation
    
  | WithAnimal Animal.Animal AnimalOperation
  | WithForm Form FormOperation
  | WithDisplayedId Id DisplayedOperation

  | SetToday Date

  | AnimalGotSaved OutsideWorld.AnimalSaveResults
  | AnimalGotCreated OutsideWorld.AnimalCreationResults

  | NewHistoryPage Animal
