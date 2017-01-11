module Animals.Animal.AnimalView exposing (compactView, expandedView)

import Html exposing (..)

import Pile.Bulma as Bulma 

import Animals.Msg exposing (..)

import Animals.Animal.Icons as Icon
import Animals.Animal.Flash as AnimalFlash exposing (AnimalFlash)

import Dict
import List

import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)


compactView : Animal -> AnimalFlash -> Html Msg
compactView animal flash =
  tr []
    [ (td []
         [ p [] ( animalSalutation animal  :: animalTags animal)
         , AnimalFlash.showWithButton flash (WithAnimal animal RemoveAnimalFlash)
           ])
      , Icon.expand animal Bulma.tdIcon
      , Icon.edit animal Bulma.tdIcon
      , Icon.moreLikeThis animal Bulma.tdIcon
      ]

expandedView : Animal -> AnimalFlash -> Html Msg      
expandedView animal flash =
    Bulma.highlightedRow []
      [ td []
          [ p [] [ animalSalutation animal ]
          , p [] (animalTags animal)
          , animalProperties animal |> Bulma.propertyTable
          , AnimalFlash.showWithButton flash (WithAnimal animal RemoveAnimalFlash)
          ]
      , Icon.contract animal Bulma.tdIcon
      , Icon.edit animal Bulma.tdIcon
      , Icon.moreLikeThis animal Bulma.tdIcon
      ]
      
-- Util

animalProperties : Animal -> List (Html msg)
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

propertyDisplayValue : DictValue -> List (Html msg)
propertyDisplayValue value =     
  case value of
    AsBool b m -> boolExplanation b m
    AsString s _ -> [text s]
    _ -> [text "unimplemented"]

boolExplanation : Bool -> String -> List (Html msg)
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



animalSalutation : Animal -> Html msg
animalSalutation animal =
  text <| animal.name ++ (parentheticalSpecies animal)

animalTags : Animal -> List (Html Msg)
animalTags animal =
  List.map Bulma.readOnlyTag animal.tags

parentheticalSpecies : Animal -> String
parentheticalSpecies animal =
  " (" ++ animal.species ++ ")"
