module Animals.Animal.ReadOnlyViews exposing (compactView, expandedView)

import Html exposing (..)
import Html.Attributes exposing (..)

import Pile.Bulma as Bulma 
import Pile.HtmlShorthand exposing (..)

import Animals.Msg exposing (..)

import Animals.Animal.Icons as Icon
import Animals.Animal.Flash as Flash

import Dict
import List
import String
import String.Extra as String

import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)

compactView animal flash =
  tr []
    [ (td []
         [ p [] ( animalSalutation animal  :: animalTags animal)
         , Flash.showAndCancel flash (UpsertCompactAnimal animal)
         ])
    , Icon.expand animal Bulma.tdIcon
    , Icon.edit animal Bulma.tdIcon
    , Icon.moreLikeThis animal Bulma.tdIcon
    ]

expandedView animal flash =
  Bulma.highlightedRow []
    [ td []
        [ p [] [ animalSalutation animal ]
        , p [] (animalTags animal)
        , animalProperties animal |> Bulma.propertyTable
        , Flash.showAndCancel flash (UpsertExpandedAnimal animal)
        ]
    , Icon.contract animal Bulma.tdIcon
    , Icon.edit animal Bulma.tdIcon
    , Icon.moreLikeThis animal Bulma.tdIcon
    ]

-- Util

animalProperties animal =
  let
    row (key, value) = 
      tr []
        [ td [] [text key]
        , td [] (propertyDisplayValue value)
        ]
    propertyPairs = Dict.toList (animal.properties)
  in
      List.map row propertyPairs

propertyDisplayValue value =     
  case value of
    AsBool b m -> boolExplanation b m
    AsString s _ -> [text s]
    _ -> [text "unimplemented"]

boolExplanation b explanation = 
  let
    icon = case b of
             True -> Bulma.trueIcon
             False -> Bulma.falseIcon
    suffix = case explanation of
               "" -> ""
               s -> " (" ++ s ++ ")"
  in
    [icon, text suffix]



animalSalutation animal =
  text <| (String.toSentenceCase animal.name) ++ (parentheticalSpecies animal)

animalTags animal =
  List.map Bulma.readOnlyTag animal.tags

parentheticalSpecies animal =
  " (" ++ animal.species ++ ")"


