module Animals.Animal.Form exposing (..)

import Dict
import Html exposing (..)
import List
import List.Extra as List
import String
import String.Extra as String

import Pile.Bulma as Bulma exposing (FormValue, Urgency(..), Validity(..))
import Pile.HtmlShorthand exposing (..)

import Animals.Msg exposing (..)
import Animals.Animal.Types exposing (..)
import Animals.Animal.Constructors exposing (..)
import Animals.Animal.Flash as AnimalFlash exposing (AnimalFlash)
import Animals.Animal.Lenses exposing (..)

freshValue : t -> FormValue t
freshValue v =
  FormValue Valid v []

extractForm : Animal -> Form
extractForm animal =
  { status = AllGood
  , id = animal.id
  , name = freshValue animal.name
  , tags = animal.tags
  , tentativeTag = ""
  , properties = animal.properties
  }

-- This is used as the default value in "impossible" cases.  
nullForm =
  { status = SomeBad
  , id = "impossible"
  , name = freshValue "you should never see this"
  , tags = []
  , tentativeTag = ""
  , properties = Dict.empty
  }

assumeValid : Form -> Form 
assumeValid form =
  { status = AllGood
  , id = form.id
  , name = freshValue form.name.value
  , tags = form.tags
  , tentativeTag = form.tentativeTag
  , properties = form.properties
  }
      

  
  
-- -- Constructing Messages and other Important Actions

updateAnimal : Form -> Animal -> Animal
updateAnimal form animal =
  let
    tags =
      case String.isEmpty form.tentativeTag of
        True -> form.tags
        False -> List.append form.tags [form.tentativeTag]
  in
    animal 
      |> animal_name.set form.name.value
      |> animal_properties.set form.properties -- Currently not edited
      |> animal_tags.set tags


saveFlash : Form -> AnimalFlash
saveFlash form =             
  case String.isEmpty form.tentativeTag of
    True -> AnimalFlash.NoFlash
    False -> AnimalFlash.SavedIncompleteTag form.tentativeTag


-- checkEditMsg : Animal -> Form -> Msg
-- checkEditMsg animal form =
--   CheckFormChange animal form

-- applyEditsMsg : Animal -> Form -> Msg        
-- applyEditsMsg animal form =
--   let
--     (newAnimal, flash) = applyEditsToAnimal animal form
--     msg = case newAnimal.wasEverSaved of
--               True -> StartSavingAnimalChanges
--               False -> StartCreatingNewAnimal
--   in
--     msg (expanded newAnimal |> andFlash flash)


textFieldEditHandler : DisplayedAnimal -> Form -> FormLens String -> (String -> Msg)
textFieldEditHandler displayed form lens =
  let
    newStringToValidate string = lens.set (freshValue string) form
  in
    newStringToValidate >> CheckFormChange displayed
