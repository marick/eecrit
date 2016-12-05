module Animals.Msg exposing (Id, Msg(..))

import Animals.Animal.Types exposing (PersistentAnimal)
import Date exposing (Date)

type alias Id = String

type Msg
  = NavigateToAllPage
  | NavigateToSpreadsheetPage
  | NavigateToSummaryPage
  | NavigateToAddPage
  | NavigateToHelpPage

  | SetToday (Maybe Date)
  | SetAnimals (List PersistentAnimal)

  | NoOp

