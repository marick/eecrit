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
import Animals.Animal.Flash as Flash
import Animals.Animal.Lenses exposing (..)

freshValue : t -> FormValue t
freshValue v =
  FormValue Valid v []

extractForm : Animal -> Form
extractForm animal =
  { isValid = True
  , name = freshValue animal.name
  , tags = animal.tags
  , tentativeTag = ""
  , properties = animal.properties
  }

freshEditableAnimal id =
  let 
    animal = { id = id
             , version = 0
             , wasEverSaved = False
             , name = ""
             , species = "bovine"
             , tags = []
             , properties = Dict.empty
             }
    form = extractForm animal
  in
    DisplayedAnimal animal (Editable form) Flash.NoFlash
  
-- Constructing Messages and other Important Actions

updateAnimal animal form =
  let
    update tags =
      animal 
        |> animal_name.set form.name.value
        |> animal_properties.set form.properties -- Currently not edited
        |> animal_tags.set tags
  in
    case String.isEmpty form.tentativeTag of
      True ->
        ( update form.tags
        , Flash.NoFlash
        )
      False ->
        ( update <| List.append form.tags [form.tentativeTag]
        , Flash.SavedIncompleteTag form.tentativeTag
        )

checkEditMsg : Animal -> Form -> Msg
checkEditMsg animal form =
  CheckFormChange animal form Flash.NoFlash

applyEditsMsg : Animal -> Form -> Msg        
applyEditsMsg animal form =
  let
    (newAnimal, flash) = updateAnimal animal form
    msg = case newAnimal.wasEverSaved of
              True -> StartSavingAnimalChanges
              False -> StartCreatingNewAnimal
  in
    msg (expanded newAnimal flash)

cancelEditsMsg : Animal -> Msg
cancelEditsMsg animal = 
  (CancelAnimalChanges animal Flash.NoFlash)

textFieldEditHandler : Animal -> Form -> StringLens Form -> (String -> Msg)
textFieldEditHandler animal form lens =
  let
    newStringToValidate string = lens.set (freshValue string) form
  in
    checkEditMsg animal << newStringToValidate
