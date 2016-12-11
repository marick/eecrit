module Animals.Animal.EditableView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import Pile.Bulma as Bulma 
import Pile.HtmlShorthand exposing (..)

import Animals.Animal.Model exposing (..)
import Animals.Msg exposing (..)
import Animals.Animal.Edit exposing (..)

import Animals.Animal.Crud exposing (..)


view animal form flash =
  Bulma.highlightedRow []
    [ td []
        [ Bulma.controlRow "Name" <| nameEditControl animal form
        , Bulma.controlRow "Tags" <| deleteTagControl animal form
        , Bulma.controlRow "New Tag" <| newTagControl animal form
            
        -- , Bulma.controlRow "Properties"
        --     <| Bulma.oneReasonablySizedControl
        --          (editableAnimalProperties form |> Bulma.propertyTable)

        , Bulma.leftwardSuccess (isSafeToSave form) (applyEdits animal form)
        , Bulma.rightwardCancel (UpsertExpandedAnimal animal NoFlash)
        , showFlash flash (UpsertEditableAnimal animal form)
        ]
    , td [] []
    , td [] []
    , editHelp Bulma.tdIcon
    ]

