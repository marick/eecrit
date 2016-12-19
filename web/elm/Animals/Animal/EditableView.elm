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

        -- TODO: NO SAVE
        , saveButton animal form form.isValid
        , cancelButton animal
        , Flash.showAndCancel flash (CheckFormChange animal form)
        ]
    , td [] []
    , td [] []
    , Icon.editHelp Bulma.tdIcon
    ]
    

-- Controls

saveButton animal form isSafeToSave = 
  Bulma.leftwardSuccess isSafeToSave (Form.applyEdits animal form)

cancelButton animal =
  Bulma.rightwardCancel (CancelAnimalChanges animal Flash.NoFlash)

nameEditControl : Animal -> Form -> Html Msg    
nameEditControl animal form =
  let
    newStringToValidate string =
      form_name_v2.set (Form.freshValue string) form
    onInput string = Form.updateForm animal (newStringToValidate string)
  in
    Bulma.soleTextInputInRow form.name_v2
      [ Events.onInput onInput
      ]

deleteTagControl animal form =
  let
    onDelete name =
      Form.updateForm animal (form_tags.update (List.remove name) form)
  in
    Bulma.horizontalControls 
      (List.map (Bulma.deletableTag onDelete) form.tags)


newTagControl animal form =
  let
    onInput value = Form.updateForm animal (form_tentativeTag.set value form)
    submitForm =
      form
      |> form_tags.set (List.append form.tags [form.tentativeTag])
      |> form_tentativeTag.set ""
    onSubmit =
      Form.updateForm animal submitForm
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



    
