module Animals.Animal.Form exposing (..)

import Dict
import Html exposing (..)
import List
import List.Extra as List
import String
import Pile.Namelike as Namelike

import Pile.Bulma as Bulma exposing
  (FormStatus(..), FormValue, Urgency(..), Validity(..))
import Pile.HtmlShorthand exposing (..)

import Animals.Msg exposing (..)
import Animals.Animal.Types exposing (..)
import Animals.Animal.Constructors exposing (..)
import Animals.Animal.Flash as AnimalFlash exposing (AnimalFlash)
import Animals.Animal.Lenses exposing (..)

extractForm : Animal -> Form
extractForm animal =
  { status = AllGood
  , id = animal.id
  , name = Bulma.freshValue animal.name
  , tags = animal.tags
  , tentativeTag = ""
  , properties = animal.properties
  }

-- This is used as the default value in "impossible" cases.  
nullForm =
  { status = SomeBad
  , id = "impossible"
  , name = Bulma.freshValue "you should never see this"
  , tags = []
  , tentativeTag = ""
  , properties = Dict.empty
  }

assumeValid : Form -> Form 
assumeValid form =
  { status = AllGood
  , id = form.id
  , name = Bulma.freshValue form.name.value
  , tags = form.tags
  , tentativeTag = form.tentativeTag
  , properties = form.properties
  }
      

  
  
-- -- Constructing Messages and other Important Actions

appliedForm : Form -> Animal -> Animal
appliedForm form animal =
  animal 
    |> animal_name.set form.name.value
    |> animal_properties.set form.properties -- Currently not edited
    |> animal_tags.set (Namelike.perhapsAdd form.tentativeTag form.tags)

saveFlash : Form -> AnimalFlash
saveFlash form =
  case Namelike.isValidAddition form.tentativeTag form.tags of
    True -> AnimalFlash.SavedIncompleteTag form.tentativeTag
    False -> AnimalFlash.NoFlash
