module Animals.Types.Form exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal exposing (Animal)

import Pile.Namelike exposing (Namelike)
import Pile.Css.H as Css
import Pile.DateHolder as DateHolder exposing (DateHolder)

import Dict exposing (Dict)

type alias Form = 
  { id : Id
  , sortKey : String  -- Distinct from name so that changing the name
                      -- doesn't cause list entries to change position
  , effectiveDate : DateHolder
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

fresh : DateHolder -> Namelike -> Id -> Form
fresh effectiveDate species id =
  { id = id
  , species = species
  , effectiveDate = effectiveDate
  , sortKey = id -- Causes forms to stay in original order
  , intendedVersion = 1
  , name = emptyNameWithNotice
  , tags = []
  , tentativeTag = ""
  , properties = Dict.empty
  , status = Css.SomeBad
  , originalAnimal = Nothing
  }
  
emptyNameWithNotice : Css.FormValue String
emptyNameWithNotice =
  Css.freshValue "" |> Css.invalidate "Give the animal a name."
