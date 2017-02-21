module Animals.Types.Form exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal exposing (Animal)

import Pile.Namelike exposing (Namelike)
import Pile.Css.H as Css
import Pile.DateHolder as DateHolder exposing (DateHolder)

import Date exposing (Date)
import Dict exposing (Dict)
import Maybe.Extra as Maybe

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

isCreational : Form -> Bool
isCreational form = Maybe.isNothing form.originalAnimal

isEdit : Form -> Bool
isEdit = not << isCreational

makeCreational : Form -> Form         
makeCreational form =
  { form | originalAnimal = Nothing }

{-! If there is an original animal to work with, partially apply the
    given function to that animal. The given function is expected to
    transform some value with that function. If there is no animal,
    `identity` is used.

    Typically used to make transformations of Model that mean nothing
    if there's no original animal. (Very likely an "impossible" case.)

    model |> Form.givenOriginalAnimal form upsertAnimal |> noCmd
-}             
givenOriginalAnimal : Form -> (Animal -> anything -> anything)
                    -> (anything -> anything)
givenOriginalAnimal form f  =
  case form.originalAnimal of
    Nothing -> identity
    Just animal -> f animal

animalCreationDate : Form -> Date                   
animalCreationDate form =
  case form.originalAnimal of
    Nothing -> DateHolder.convertToDate form.effectiveDate
    Just animal -> animal.creationDate

{-! At any given moment, a form's animal can have two names: the name of
    the animal being edited (if any), and the current name on the form.
-}
names : Form -> List Namelike
names form =
  Maybe.values [ Maybe.map .name form.originalAnimal, Just form.name.value ]
  
