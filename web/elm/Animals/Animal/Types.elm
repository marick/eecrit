module Animals.Animal.Types exposing
  (
  ..
  )

import Animals.Animal.Flash as Flash exposing (Flash)
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
  }
  
type alias DisplayedAnimal = 
  { animal : Animal
  , display : Display
  , flash : Flash
  }

compact animal flash =
  DisplayedAnimal animal (Display AllPage Compact) flash
expanded animal flash =
  DisplayedAnimal animal (Display AllPage Expanded) flash
editable animal form flash =
  DisplayedAnimal animal (Display AllPage <| Editable form) flash
new animal form flash = 
  DisplayedAnimal animal (Display AddPage <| Editable form) flash
    
type alias ValidationContext =
  { disallowedNames : Set String
  }

