module Animals.Types.Animal exposing (..)

import Animals.Types.Basic exposing (..)

type alias Animal =
  { id : Id
  , displayFormat : Format
  , version : Int
  , name : String
  , species : String
  , tags : List String
  , properties : Properties
  }

type Format
  = Compact
  | Expanded


