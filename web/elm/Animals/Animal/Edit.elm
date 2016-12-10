module Animals.Animal.Edit exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import List
import List.Extra as List
import String
import String.Extra as String

import Pile.Bulma as Bulma 
import Pile.HtmlShorthand exposing (..)

import Animals.Animal.Model exposing (..)
import Animals.Msg exposing (..)

reviseDisplay : Animal -> Display -> Msg
reviseDisplay animal newDisplay =
  displayWithFlash animal newDisplay NoFlash

cancelFlash = reviseDisplay -- use for emphasis
    
displayWithFlash : Animal -> Display -> Flash -> Msg
displayWithFlash animal newDisplay flash =
  ReviseDisplayedAnimal <| DisplayedAnimal animal newDisplay flash 

--   

updateForm : Animal -> Form -> Msg
updateForm animal form =
  reviseDisplay animal (Editable form)

beginEditing : Animal -> Msg
beginEditing animal =
  updateForm animal (extractForm animal)

validate : String -> value -> (value -> Bool) -> Result (value, String) value 
validate requirement value pred =
  if pred value then
    Ok value
  else
    Err (value, requirement)

validatedName form =
  validate "The animal has to have a name!"
    (form_name.get form)
    (not << String.isEmpty)

-- This is way too fragile
isSafeToSave form =
  case validatedName form of
    Ok x -> True
    Err x -> False

nameEditControl animal form = 
  let
    onInput value = updateForm animal (form_name.set value form)
  in
    Bulma.soleTextInputInRow (validatedName form)
      [ Events.onInput onInput
      ]

deleteTagControl animal form =
  let
    onDelete name =
      updateForm animal (form_tags.update (List.remove name) form)
  in
    Bulma.horizontalControls 
      (List.map (Bulma.deletableTag onDelete) form.tags)


newTagControl animal form =
  let
    onInput value = updateForm animal (form_tentativeTag.set value form)
    submitForm =
      form
      |> form_tags.set (List.append form.tags [form.tentativeTag])
      |> form_tentativeTag.set ""
    onSubmit =
      updateForm animal submitForm
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
--           [ input [type' "checkbox", class "control", checked b]  []
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

