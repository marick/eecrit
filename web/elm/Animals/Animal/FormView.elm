module Animals.Animal.FormView exposing (view)

import Html exposing (..)
import Html.Events as Events

import Pile.Bulma as Bulma exposing
  (FormStatus(..), FormValue, Urgency(..), Validity(..))

import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)

import Animals.Animal.Icons as Icon
import Animals.Animal.Flash as Flash exposing (AnimalFlash)

view : Form -> AnimalFlash -> (FormOperation, FormOperation) -> Html Msg
view form flash (saveOp, cancelOp) =
  Bulma.highlightedRow []
    [ td []
        [ -- Bulma.controlRow "Name" <| nameEditControl displayed form
--        , Bulma.controlRow "Tags" <| deleteTagControl displayed form
--        , Bulma.controlRow "New Tag" <| newTagControl displayed form
          
        -- , Bulma.leftwardSave form.status (WithForm form saveOp)
        -- , Bulma.rightwardCancel form.status (WithForm form cancelOp)
--        , Flash.showWithButton flash (WithAnimal displayed RemoveFlash)
        ]
    , td [] []
    , td [] []
    -- , Icon.editHelp Bulma.tdIcon
    ]
    

-- Controls

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
      


-- -- editableAnimalProperties form =
-- --   let
-- --     row (key, value) = 
-- --       tr []
-- --         [ td [] [text key]
-- --         , td [] (propertyEditValue value)
-- --         ]
-- --   in
-- --     List.map row form.properties

-- -- propertyEditValue pval =
-- --   case pval of
-- --     AsBool b m ->
-- --       [ Bulma.horizontalControls 
-- --           [ input [type_ "checkbox", class "control", checked b]  []
-- --           , Bulma.oneTextInputInRow
-- --               [ value (Maybe.withDefault "" m)
-- --               , placeholder "notes if desired"
-- --               ]
-- --           ]
-- --       ]
-- --     AsString s ->
-- --       [Bulma.soleTextInputInRow [value s]]
-- --     _ ->
-- --       [text "unimplemented"]



    
