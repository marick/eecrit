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

import Animals.Types exposing (..)
import Animals.Lenses exposing (..)
import Animals.Msg exposing (..)

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
