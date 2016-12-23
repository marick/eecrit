module Animals.Animal.Types exposing
  (
  ..
  )

import Animals.Animal.Flash as Flash exposing (AnimalFlash(..))
import Animals.Pages.Declare exposing (PageChoice(..))
import Pile.Bulma exposing (FormValue)
import Dict exposing (Dict)
import Date exposing (Date)
import Set exposing (Set)
import String

type alias Id = String

type DictValue
  = AsInt Int String
  | AsFloat Float String
  | AsString String String
  | AsDate Date String
  | AsBool Bool String

type alias Animal =
  { id : Id
  , version : Int
  , wasEverSaved : Bool 
  , name : String
  , species : String
  , tags : List String
  , properties : Dict String DictValue
  }

type alias Form = 
  { name : FormValue String
  , tags : List String
  , tentativeTag : String
  , properties : Dict String DictValue
  , isValid : Bool
  }

type DisplayHow
  = Compact
  | Expanded
  | Editable Form

type alias Display =
  { wherein : PageChoice
  , how : DisplayHow
  , animalFlash : AnimalFlash
  }
  
type alias DisplayedAnimal = 
  { animal : Animal
  , display : Display
  }

type alias ValidationContext =
  { disallowedNames : Set String
  }

