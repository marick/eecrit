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

type alias MsgMaker = DisplayedAnimal -> Form -> Msg

editableView : DisplayedAnimal -> Form -> MsgMaker -> MsgMaker -> Html Msg
editableView displayed form makeSaveMsg makeCancelMsg =
  Bulma.highlightedRow []
    [ td []
        [ Bulma.controlRow "Name" <| nameEditControl displayed form
        , Bulma.controlRow "Tags" <| deleteTagControl displayed form
        , Bulma.controlRow "New Tag" <| newTagControl displayed form
          
        -- , Bulma.controlRow "Properties"
        --     <| Bulma.oneReasonablySizedControl
        --          (editableAnimalProperties form |> Bulma.propertyTable)
          
        , saveButton displayed form makeSaveMsg
        , cancelButton displayed form makeCancelMsg
        , Flash.showWithButton displayed.animalFlash (RemoveFlash displayed)
        ]
    , td [] []
    , td [] []
    , Icon.editHelp Bulma.tdIcon
    ]
    

-- Controls

saveButton : DisplayedAnimal -> Form -> MsgMaker -> Html Msg
saveButton displayed form msgMaker =
  Bulma.leftwardSave form.status (msgMaker displayed form)

cancelButton : DisplayedAnimal -> Form -> MsgMaker -> Html Msg
cancelButton displayed form msgMaker =
  Bulma.rightwardCancel form.status (msgMaker displayed form)

nameEditControl : DisplayedAnimal -> Form -> Html Msg    
nameEditControl displayed form =
  let
    handleNewText string =
      CheckFormChange displayed <| form_name.set (Bulma.freshValue string) form
  in
    Bulma.soleTextInputInRow
      form.status
      form.name
      [ Events.onInput handleNewText ]

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



    
