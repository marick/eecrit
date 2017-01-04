module Animals.Animal.EditableView exposing (editableView)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events

import List.Extra as List
import Pile.Bulma as Bulma exposing
  (FormStatus(..), FormValue, Urgency(..), Validity(..))
import Set

import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)

import Animals.Animal.Icons as Icon
import Animals.Animal.Flash as Flash
import Animals.Animal.Form as Form
import Animals.Animal.Lenses exposing (..)

editableView : DisplayedAnimal -> Form -> (FormOperation, FormOperation) -> Html Msg
editableView displayed form (saveOp, cancelOp) =
  Bulma.highlightedRow []
    [ td []
        [ Bulma.controlRow "Name" <| nameEditControl displayed form
        , Bulma.controlRow "Tags" <| deleteTagControl displayed form
        , Bulma.controlRow "New Tag" <| newTagControl displayed form
          
        -- , Bulma.controlRow "Properties"
        --     <| Bulma.oneReasonablySizedControl
        --          (editableAnimalProperties form |> Bulma.propertyTable)
          
        , Bulma.leftwardSave form.status (WithForm form saveOp)
        , Bulma.rightwardCancel form.status (WithForm form cancelOp)
        , Flash.showWithButton displayed.animalFlash (WithAnimal displayed RemoveFlash)
        ]
    , td [] []
    , td [] []
    , Icon.editHelp Bulma.tdIcon
    ]
    

-- Controls

nameEditControl : DisplayedAnimal -> Form -> Html Msg
nameEditControl displayed form =
  Bulma.soleTextInputInRow
    form.status
    form.name
    [ Events.onInput (WithForm form << NameFieldUpdate) ]

deleteTagControl displayed form =
  let
    onDelete name =
      CheckFormChange displayed (form_tags.update (List.remove name) form)
  in
    Bulma.horizontalControls 
      (List.map (Bulma.deletableTag form.status onDelete) form.tags)


newTagControl displayed form =
  let
    onInput value =
      CheckFormChange displayed (form_tentativeTag.set value form)
    onSubmit =
      form
      |> form_tags.set (List.append form.tags [form.tentativeTag])
      |> form_tentativeTag.set ""
      |> CheckFormChange displayed
  in
    Bulma.textInputWithSubmit
      form.status
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



    
