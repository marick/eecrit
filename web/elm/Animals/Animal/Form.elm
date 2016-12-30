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
import Animals.Animal.Flash as Flash
import Animals.Animal.Lenses exposing (..)

freshValue : t -> FormValue t
freshValue v =
  FormValue Valid v []

extractForm : Animal -> Form
extractForm animal =
  { isValid = True
  , id = animal.id
  , name = freshValue animal.name
  , tags = animal.tags
  , tentativeTag = ""
  , properties = animal.properties
  }

-- This is used as the default value in "impossible" cases.  
nullForm =
  { isValid = False
  , id = "impossible"
  , name = freshValue "you should never see this"
  , tags = []
  , tentativeTag = ""
  , properties = Dict.empty
  }

-- assumeValid : Form -> Form 
-- assumeValid form =
--   { isValid = True
--   , name = freshValue form.name.value
--   , tags = form.tags
--   , tentativeTag = form.tentativeTag
--   , properties = form.properties
--   }
      

  
  
-- -- Constructing Messages and other Important Actions

-- updateAnimal animal form =
--   let
--     update tags =
--       animal 
--         |> animal_name.set form.name.value
--         |> animal_properties.set form.properties -- Currently not edited
--         |> animal_tags.set tags
--   in
--     case String.isEmpty form.tentativeTag of
--       True ->
--         ( update form.tags
--         , Flash.NoFlash
--         )
--       False ->
--         ( update <| List.append form.tags [form.tentativeTag]
--         , Flash.SavedIncompleteTag form.tentativeTag
--         )

-- checkEditMsg : Animal -> Form -> Msg
-- checkEditMsg animal form =
--   CheckFormChange animal form

-- applyEditsMsg : Animal -> Form -> Msg        
-- applyEditsMsg animal form =
--   let
--     (newAnimal, flash) = updateAnimal animal form
--     msg = case newAnimal.wasEverSaved of
--               True -> StartSavingAnimalChanges
--               False -> StartCreatingNewAnimal
--   in
--     msg (expanded newAnimal |> andFlash flash)

cancelEditsMsg : DisplayedAnimal -> Msg
cancelEditsMsg animal = 
  CancelAnimalChanges animal

-- textFieldEditHandler : Animal -> Form -> FormLens String -> (String -> Msg)
-- textFieldEditHandler animal form lens =
--   let
--     -- Note: this wiping out of the state of the value is redundant
--     -- with what's done as the form is checked. However, there isn't
--     -- really anything better to do. We don't check the form here
--     -- because checking often requires context (like what all the animal
--     -- names are) and it seems wrong to push groveling over the model
--     -- all the way down to (what amounts to) view code. 
--     newStringToValidate string = lens.set (freshValue string) form
--   in
--     checkEditMsg animal << newStringToValidate
