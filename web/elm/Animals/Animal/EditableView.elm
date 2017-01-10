module Animals.Animal.EditableView exposing (..)

import Html exposing (..)
import Html.Events as Events

import Pile.Bulma as Bulma exposing
  (FormStatus(..), FormValue, Urgency(..), Validity(..))

import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)

import Animals.Animal.Icons as Icon
import Animals.Animal.Flash as Flash

x = 5

-- editableView : DisplayedAnimal -> Form -> (FormOperation, FormOperation) -> Html Msg
-- editableView displayed form (saveOp, cancelOp) =
--   Bulma.highlightedRow []
--     [ td []
--         [ Bulma.controlRow "Name" <| nameEditControl displayed form
--         , Bulma.controlRow "Tags" <| deleteTagControl displayed form
--         , Bulma.controlRow "New Tag" <| newTagControl displayed form
          
--         -- , Bulma.controlRow "Properties"
--         --     <| Bulma.oneReasonablySizedControl
--         --          (editableAnimalProperties form |> Bulma.propertyTable)
          
--         , Bulma.leftwardSave form.status (WithForm form saveOp)
--         , Bulma.rightwardCancel form.status (WithForm form cancelOp)
--         , Flash.showWithButton displayed.animalFlash (WithAnimal displayed RemoveFlash)
--         ]
--     , td [] []
--     , td [] []
--     , Icon.editHelp Bulma.tdIcon
--     ]
    

-- -- Controls

-- nameEditControl : DisplayedAnimal -> Form -> Html Msg
-- nameEditControl displayed form =
--   Bulma.soleTextInputInRow
--     form.status
--     form.name
--     [ Events.onInput (WithForm form << NameFieldUpdate) ]

-- deleteTagControl : DisplayedAnimal -> Form -> Html Msg
-- deleteTagControl displayed form =
--   let
--     onDelete name = WithForm form (DeleteTag name)
--   in
--     Bulma.horizontalControls 
--       (List.map (Bulma.deletableTag form.status onDelete) form.tags)


-- newTagControl : DisplayedAnimal -> Form -> Html Msg
-- newTagControl displayed form =
--   let
--     onInput = WithForm form << TentativeTagUpdate
--     onSubmit = WithForm form CreateNewTag 
--   in
--     Bulma.textInputWithSubmit
--       form.status
--       "Add"
--       form.tentativeTag
--       onInput
--       onSubmit
      

