module Animals.Msg exposing (Id, Msg(..))

import Animals.Types exposing (..)
import Date exposing (Date)

type alias Id = String

type Msg

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

