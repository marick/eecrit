module Animals.Animal.Form exposing (..)

import Dict
import Html exposing (..)
import List
import List.Extra as List
import String
import String.Extra as String

import Pile.Bulma as Bulma 
import Pile.HtmlShorthand exposing (..)

import Animals.Msg exposing (..)
import Animals.Animal.Types exposing (..)
import Animals.Animal.Flash as Flash
import Animals.Animal.Lenses exposing (..)


extractForm : Animal -> Form
extractForm animal =
  { name = animal.name
  , tags = animal.tags
  , tentativeTag = ""
  , properties = animal.properties
  }

freshEditableAnimal id =
  let 
    animal = { id = id
             , name = ""
             , species = "bovine"
             , tags = []
             , properties = Dict.empty
             }
    form = extractForm animal
  in
    DisplayedAnimal animal (Editable form) Flash.NoFlash
  
updateAnimal animal form =
  let
    update tags =
      animal 
        |> animal_name.set form.name
        |> animal_properties.set form.properties -- Currently not edited
        |> animal_tags.set tags
  in
    case String.isEmpty form.tentativeTag of
      True ->
        Ok <| update form.tags 
      False ->
        -- Note that this isn't really an Err. Would maybe be better to make
        -- own type?
        Err ( update <| List.append form.tags [form.tentativeTag]
            , Flash.SavedIncompleteTag form.tentativeTag
            )


-- Constructing Messages and other Important Actions

updateForm : Animal -> Form -> Msg
updateForm animal form =
  UpsertEditableAnimal animal form Flash.NoFlash

beginEditing : Animal -> Msg
beginEditing animal =
  updateForm animal (extractForm animal)

applyEdits animal form =
  case updateAnimal animal form of
    Ok newAnimal ->
      UpsertExpandedAnimal newAnimal Flash.NoFlash
    Err (newAnimal, flash) ->
      UpsertExpandedAnimal newAnimal flash

