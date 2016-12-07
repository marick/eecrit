module Animals.Animal.View exposing (view)

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
import Animals.Animal.Edit exposing (..)

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
  Bulma.highlightedRow []
    [ td []
        [ p [] [ animalSalutation animal ]
        , p [] (animalTags animal)
        , animalProperties animal |> Bulma.propertyTable
        ]
    , contract animal Bulma.tdIcon
    , edit animal Bulma.tdIcon
    , moreLikeThis animal Bulma.tdIcon
    ]




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
      
        
editableView animal changes =
  Bulma.highlightedRow []
    [ td []
        [ Bulma.controlRow "Name" <| nameEditControl animal changes
        , Bulma.controlRow "Tags" <| deleteTagControl animal changes
        , Bulma.controlRow "New Tag" <| newTagControl animal changes
            
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



propertyPairs animal =
  Dict.toList (animal.properties)


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
      
