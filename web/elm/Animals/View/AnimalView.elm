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
  p [] [text animal.id]


-- Helpers

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
  ReviseDisplayedAnimal
    persistentAnimal.id
    (DisplayedAnimal persistentAnimal newDisplay)

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
    (EditAnimal animal.id)
      
moreLikeThis animal iconType =
  iconType "fa-plus"
    "Copy: make more animals like this one"
    (MoreLikeThisAnimal animal.id)
