module Animals.Animal.Types exposing
  (
  ..
  )

import Animals.View.AnimalFlash as AnimalFlash exposing (AnimalFlash(..))
import Pile.Css.H as Css
import Pile.Css.Bulma as Css
import Dict exposing (Dict)
import Date exposing (Date)
import Pile.Namelike exposing (Namelike)

type alias Id = String

type DictValue
  = AsInt Int String
  | AsFloat Float String
  | AsString String String
  | AsDate Date String
  | AsBool Bool String

type alias Animal =
  { id : Id
  , displayFormat : Format
  , version : Int
  , name : String
  , species : String
  , tags : List String
  , properties : Dict String DictValue
  }


type alias Properties = Dict String DictValue
  
type alias Form = 
  { id : Id
  , sortKey : String  -- Distinct from name so that changing the name
                        -- doesn't cause list entries to change position
  , intendedVersion : Int
  , species : Namelike
  , name : Css.FormValue Namelike
  , tags : List Namelike
  , tentativeTag : String
  , properties : Properties
  , status : Css.FormStatus
  , originalAnimal : Maybe Animal
  }

type Format
  = Compact
  | Expanded


type alias ValidationContext =
  { disallowedNames : List Namelike
  }

type Affordance
  = Writable Form
  | Viewable Animal

type alias Displayed =
  { view : Affordance
  , animalFlash : AnimalFlash
  }

formDisplay : Form -> Displayed
formDisplay form =
  Displayed (Writable form) NoFlash

animalDisplay : Animal -> Displayed
animalDisplay animal =
  Displayed (Viewable animal) NoFlash


freshForm : Namelike -> Id -> Form
freshForm species id =
  { id = id
  , sortKey = id -- Causes forms to stay in original order
  , intendedVersion = 1
  , species = species
  , name = Css.freshValue "" |> Css.invalidate "Give the animal a name."
  , tags = []
  , tentativeTag = ""
  , properties = Dict.empty
  , status = Css.SomeBad
  , originalAnimal = Nothing
  }
  
