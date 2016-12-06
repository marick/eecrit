module Animals.View.AnimalView exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import List
import String
import String.Extra as String

import Pile.Bulma as Bulma 
import Pile.HtmlShorthand exposing (..)

import Animals.Types exposing (..)
import Animals.Lenses exposing (..)
import Animals.Msg exposing (..)


view {persistent, display} =
  case display of
    Compact -> compactView persistent
    Expanded -> expandedView persistent
    Editable changing -> editableView persistent changing

compactView animal =
  tr []
    [ (td [] [ p [] ( animalSalutation animal  :: animalTags animal)])
    , expand animal Bulma.tdIcon
    , edit animal Bulma.tdIcon
    , moreLikeThis animal Bulma.tdIcon
    ]

expandedView animal =
  tr [ emphasizeBorder ]
    [ td []
        [ p [] [ animalSalutation animal ]
        , p [] (animalTags animal)
        , animalProperties animal |> Bulma.propertyTable
        ]
    , contract animal Bulma.tdIcon
    , edit animal Bulma.tdIcon
    , moreLikeThis animal Bulma.tdIcon
    ]

editableView animal changes =
  tr [ emphasizeBorder ]
    [ td []
        [ Bulma.controlRow "Name"
            <| Bulma.soleTextInputInRow [ value changes.name
                                        , Events.onInput (SetEditedName animal.id)
                                        ]
        , Bulma.controlRow "Tags"
            <| Bulma.horizontalControls 
              (List.map (Bulma.deletableTag (DeleteTagWithName animal.id))
                 changes.tags)

        , Bulma.controlRow "New Tag"
            <| Bulma.textInputWithSubmit
                 "Add"
                 changes.tentativeTag
                 (SetTentativeTag animal.id)
                 (CreateNewTag animal.id)
            
        -- , Bulma.controlRow "Properties"
        --     <| Bulma.oneReasonablySizedControl
        --          (editableAnimalProperties changes |> Bulma.propertyTable)

        , Bulma.leftwardSuccess (revise (applyEdits animal changes) Expanded)
        , Bulma.rightwardCancel (revise animal Expanded)
        ]
    , td [] []
    , td [] []
    , editHelp Bulma.tdIcon
    ]


-- Helpers

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



propertyPairs animal =
  Dict.toList (animal.properties)

emphasizeBorder =
  style [ ("border-top", "2px solid")
        , ("border-bottom", "2px solid")
        ]
    

animalProperties animal =
  let
    row (key, value) = 
      tr []
        [ td [] [text key]
        , td [] (propertyDisplayValue value)
        ]
  in
      List.map row (propertyPairs animal)

propertyDisplayValue value =     
  case value of
    AsBool b m -> boolExplanation b m
    AsString s -> [text s]
    _ -> [text "unimplemented"]

boolExplanation b explanation = 
  let
    icon = case b of
             True -> Bulma.trueIcon
             False -> Bulma.falseIcon
    suffix = case explanation of
               Nothing -> ""
               Just s -> " (" ++ s ++ ")"
  in
    [icon, text suffix]



animalSalutation animal =
  text <| (String.toSentenceCase animal.name) ++ (parentheticalSpecies animal)

animalTags animal =
  List.map Bulma.readOnlyTag animal.tags

parentheticalSpecies animal =
  " (" ++ animal.species ++ ")"

revise persistentAnimal newDisplay =
  ReviseDisplayedAnimal <| DisplayedAnimal persistentAnimal newDisplay

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

-- Various icons

expand animal iconType =
  iconType "fa-caret-down"
    "Expand: show more about this animal"
    (revise animal Expanded)
      
contract animal iconType =
  iconType "fa-caret-up"
    "Expand: show less about this animal"
    (revise animal Compact)
      
edit animal iconType =
  iconType "fa-pencil"
    "Edit: make changes to this animal"
    (revise animal <| Editable (changingAnimalValues animal))
      
moreLikeThis animal iconType =
  iconType "fa-plus"
    "Copy: make more animals like this one"
    (MoreLikeThisAnimal animal.id)

editHelp iconType = 
  iconType "fa-question-circle" "Help on editing" NoOp    
      
