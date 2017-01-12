module Animals.Animal.Types exposing
  (
  ..
  )

import Animals.Animal.Flash as Flash exposing (AnimalFlash(..))
import Pile.Bulma as Bulma exposing (FormValue, FormStatus(..), Validity(..))
import Dict exposing (Dict)
import Date exposing (Date)

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
  , species : String
  , name : FormValue String
  , tags : List String
  , tentativeTag : String
  , properties : Properties
  , status : FormStatus
  , originalAnimal : Maybe Animal
  }

type Format
  = Compact
  | Expanded


type alias ValidationContext =
  { disallowedNames : List String
  }

type Affordance
  = Writable Form
  | Viewable Animal

type alias Displayed =
  { view : Affordance
  , animalFlash : AnimalFlash
  }

formDisplay form =
  Displayed (Writable form) NoFlash
    
animalDisplay animal =
  Displayed (Viewable animal) NoFlash

freshForm species id =
  { id = id
  , sortKey = id -- Causes forms to stay in original order
  , intendedVersion = 1
  , species = species
  , name = Bulma.freshValue "" |> Bulma.invalidate "Give the animal a name."
  , tags = []
  , tentativeTag = ""
  , properties = Dict.empty
  , status = SomeBad
  , originalAnimal = Nothing
  }
  
