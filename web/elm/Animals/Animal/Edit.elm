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
import Animals.Lenses exposing (..)
import Animals.Msg exposing (..)

revise : PersistentAnimal -> AnimalDisplay -> Msg
revise persistentAnimal newDisplay =
  ReviseDisplayedAnimal <| DisplayedAnimal persistentAnimal newDisplay

nameEditControl animal changes = 
  let
    onInput value = revise animal <| Editable (form_name.set value changes)
  in
    Bulma.soleTextInputInRow [ value changes.name
                             , Events.onInput onInput
                             ]

deleteTagControl animal changes =
  let
    onDelete name =
      revise animal <| Editable <| form_tags.update (List.remove name) changes
  in
    Bulma.horizontalControls 
      (List.map (Bulma.deletableTag onDelete) changes.tags)


newTagControl animal changes =
  let
    onInput value = revise animal <| Editable (form_tentativeTag.set value changes)
    submitChanges =
      changes
      |> form_tags.set (List.append changes.tags [changes.tentativeTag])
      |> form_tentativeTag.set ""
    onSubmit =
      revise animal (Editable submitChanges)
  in
    Bulma.textInputWithSubmit
      "Add"
      changes.tentativeTag
      onInput
      onSubmit
      


-- editableAnimalProperties changes =
--   let
--     row (key, value) = 
--       tr []
--         [ td [] [text key]
--         , td [] (propertyEditValue value)
--         ]
--   in
--     List.map row changes.properties

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

changingAnimalValues source =
  { name = source.name
  , tags = source.tags
  , tentativeTag = ""
  , properties = source.properties
  }

applyEdits source changes =
  { source
      | name = changes.name
      , tags = changes.tags
      , properties = changes.properties
  }
