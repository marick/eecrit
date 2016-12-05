module Animals.Types exposing (..)

import Dict exposing (Dict)
import Date exposing (Date)

type DictValue
  = AsInt Int
  | AsFloat Float
  | AsString String
  | AsDate Date
  | AsBool Bool (Maybe String)

type alias AnimalProperties =
  Dict String DictValue
    
type alias PersistentAnimal =
  { id : String
  , name : String
  , species : String
  , tags : List String
  , properties : AnimalProperties
  }

type alias TemporaryAnimal = 
  { name : String
  , tags : List String
  , tentativeTag : String
  }

type DisplayedAnimal
  = Compact PersistentAnimal
  | Expanded PersistentAnimal
  | Editable PersistentAnimal TemporaryAnimal

