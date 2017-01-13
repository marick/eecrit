module Animals.Types.Form exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal exposing (Animal)

import Pile.Namelike exposing (Namelike)
import Pile.Css.H as Css
import Pile.Css.Bulma as Css

import Dict exposing (Dict)

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

type alias ValidationContext =
  { disallowedNames : List Namelike
  }

fresh : Namelike -> Id -> Form
fresh species id =
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
  
