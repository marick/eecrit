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
import Animals.Animal.Model exposing (..)
import Animals.Animal.Flash as Flash




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
