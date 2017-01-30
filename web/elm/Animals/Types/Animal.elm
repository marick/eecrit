module Animals.Types.Animal exposing (..)

import Animals.Types.Basic exposing (..)
import Date exposing (Date)

type alias Animal =
  { id : Id
  , displayFormat : Format
  , version : Int
  , name : String
  , species : String
  , tags : List String
  , properties : Properties
  , creationDate : Date
  }

type Format
  = Compact
  | Expanded


