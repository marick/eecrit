module Animals.Animal.EditableView exposing (view)

import Html exposing (..)

import Pile.Bulma as Bulma 

import Animals.Animal.Model exposing (..)
import Animals.Msg exposing (..)
import Animals.Animal.Edit exposing (..)

import Animals.Animal.CommonView exposing (..)
import Animals.Animal.Icons as Icon
import Animals.Animal.Flash as Flash

view animal form flash =
  Bulma.highlightedRow []
    [ td []
        [ Bulma.controlRow "Name" <| nameEditControl animal form
        , Bulma.controlRow "Tags" <| deleteTagControl animal form
        , Bulma.controlRow "New Tag" <| newTagControl animal form
            
        -- , Bulma.controlRow "Properties"
        --     <| Bulma.oneReasonablySizedControl
        --          (editableAnimalProperties form |> Bulma.propertyTable)

        , saveButton animal form
        , cancelButton animal
        , Flash.showAndCancel flash (UpsertEditableAnimal animal form)
        ]
    , td [] []
    , td [] []
    , Icon.editHelp Bulma.tdIcon
    ]

saveButton animal form = 
  Bulma.leftwardSuccess (isSafeToSave form) (applyEdits animal form)

cancelButton animal =
  Bulma.rightwardCancel (UpsertExpandedAnimal animal Flash.NoFlash)

applyEdits animal form =
  case updateAnimal animal form of
    Ok newAnimal ->
      UpsertExpandedAnimal newAnimal Flash.NoFlash
    Err (newAnimal, flash) ->
      UpsertExpandedAnimal newAnimal flash
