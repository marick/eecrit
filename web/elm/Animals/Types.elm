module Animals.Types exposing (..)

import Dict exposing (Dict)
import Date exposing (Date)

type DisplayState
  = Compact
  | Expanded
  | Editable

type DictValue
  = AsInt Int
  | AsFloat Float
  | AsString String
  | AsDate Date
  | AsBool Bool (Maybe String)

type alias AnimalProperties =
  Dict String DictValue

type alias Animal =
  { id : String
  , name : String
  , species : String
  , tags : List String
  , properties : AnimalProperties
  , displayState : DisplayState
  , editableCopy : Maybe EditableAnimal
  }

type alias EditableAnimal =
  { name : String
  , tags : List String
  , tentativeTag : String
  }

