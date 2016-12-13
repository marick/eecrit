module Animals.Animal.Types exposing
  (
  ..
  )

import Animals.Animal.Flash as Flash exposing (Flash)
import Animals.Animal.Lenses exposing (..)

import Dict exposing (Dict)
import Date exposing (Date)
import String

type alias Id = String

type DictValue
  = AsInt Int
  | AsFloat Float
  | AsString String
  | AsDate Date
  | AsBool Bool (Maybe String)

type alias Animal =
  { id : Id
  , wasEverSaved : Bool 
  , name : String
  , species : String
  , tags : List String
  , properties : Dict String DictValue
  }

type alias Form = 
  { name : String
  , tags : List String
  , tentativeTag : String
  , properties : Dict String DictValue
  }

type Display
  = Compact
  | Expanded
  | Editable Form
  
type alias DisplayedAnimal = 
  { animal : Animal
  , display : Display
  , flash : Flash
  }

compact animal flash =
  DisplayedAnimal animal Compact flash
expanded animal flash =
  DisplayedAnimal animal Expanded flash
editable animal form flash =
  DisplayedAnimal animal (Editable form) flash
    
