module Animals.Animal.EditableView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events

import List.Extra as List
import Pile.Bulma as Bulma exposing (FormValue, Urgency(..), Validity(..))
import Set

import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)

import Animals.Animal.Icons as Icon
import Animals.Animal.Flash as Flash
import Animals.Animal.Form as Form
import Animals.Animal.Validation as Validation
import Animals.Animal.Lenses exposing (..)

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
        , Flash.showAndCancel flash (CheckFormChange animal form)
        ]
    , td [] []
    , td [] []
    , Icon.editHelp Bulma.tdIcon
    ]
    

-- Controls

saveButton animal form = 
  Bulma.leftwardSuccess form.isValid (Form.applyEditsMsg animal form)

cancelButton animal =
  Bulma.rightwardCancel (Form.cancelEditsMsg animal)

nameEditControl : Animal -> Form -> Html Msg    
nameEditControl animal form =
  Bulma.soleTextInputInRow
    form.name
    [ Events.onInput (Form.textFieldEditHandler animal form form_name) ]

deleteTagControl animal form =
  let
    onDelete name =
      Form.checkEditMsg animal (form_tags.update (List.remove name) form)
  in
    Bulma.horizontalControls 
      (List.map (Bulma.deletableTag onDelete) form.tags)


newTagControl animal form =
  let
    onInput value =
      Form.checkEditMsg animal (form_tentativeTag.set value form)
    onSubmit =
      form
      |> form_tags.set (List.append form.tags [form.tentativeTag])
      |> form_tentativeTag.set ""
      |> Form.checkEditMsg animal
  in
    Bulma.textInputWithSubmit
      "Add"
      form.tentativeTag
      onInput
      onSubmit
      


-- editableAnimalProperties form =
--   let
--     row (key, value) = 
--       tr []
--         [ td [] [text key]
--         , td [] (propertyEditValue value)
--         ]
--   in
--     List.map row form.properties

-- propertyEditValue pval =
--   case pval of
--     AsBool b m ->
--       [ Bulma.horizontalControls 
--           [ input [type_ "checkbox", class "control", checked b]  []
--           , Bulma.oneTextInputInRow
--               [ value (Maybe.withDefault "" m)
--               , placeholder "notes if desired"
--               ]
--           ]
--       ]
--     AsString s ->
--       [Bulma.soleTextInputInRow [value s]]
--     _ ->
--       [text "unimplemented"]



    
