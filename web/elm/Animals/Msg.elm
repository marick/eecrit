module Animals.Msg exposing (Id, Msg(..))

import Animals.Types exposing (PersistentAnimal)
import Date exposing (Date)

type alias Id = String

type Msg
  = NavigateToAllPage
  | NavigateToAddPage
  | NavigateToHelpPage

  | SetToday (Maybe Date)
  | SetAnimals (List PersistentAnimal)

  | ToggleDatePicker
  | SelectDate Date

  | SetNameFilter String
  | SetTagFilter String
  | SetSpeciesFilter String

  | ExpandAnimal Id
  | ContractAnimal Id
  | EditAnimal Id
  | SetEditedName Id String
  | DeleteTagWithName Id String
  | SetTentativeTag Id String
  | CreateNewTag Id
  | CancelAnimalEdit Id
  | SaveAnimalEdit Id

  | MoreLikeThisAnimal Id

  | NoOp

