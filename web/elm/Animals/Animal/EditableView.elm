module Animals.Animal.EditableView exposing (view)

import Html exposing (..)

import Pile.Bulma as Bulma 

import Animals.Animal.Model exposing (..)
import Animals.Msg exposing (..)

import Animals.Animal.ViewUtil exposing (..)
import Animals.Animal.Icons as Icon
import Animals.Animal.Flash as Flash
import Animals.Animal.Edit as Edit

view animal form flash =
  Bulma.highlightedRow []
    [ td []
        [ Bulma.controlRow "Name" <| Edit.nameEditControl animal form
        , Bulma.controlRow "Tags" <| Edit.deleteTagControl animal form
        , Bulma.controlRow "New Tag" <| Edit.newTagControl animal form
            
        -- , Bulma.controlRow "Properties"
        --     <| Bulma.oneReasonablySizedControl
        --          (editableAnimalProperties form |> Bulma.propertyTable)

        , Edit.saveButton animal form
        , Edit.cancelButton animal
        , Flash.showAndCancel flash (UpsertEditableAnimal animal form)
        ]
    , td [] []
    , td [] []
    , Icon.editHelp Bulma.tdIcon
    ]
