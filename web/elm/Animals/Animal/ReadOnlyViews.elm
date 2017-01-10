module Animals.Animal.ReadOnlyViews exposing (..)

import Html exposing (..)

import Pile.Bulma as Bulma 

import Animals.Msg exposing (..)

import Animals.Animal.Icons as Icon
import Animals.Animal.Flash as AnimalFlash

import Dict
import List

import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)

compactView : Animal -> Html Msg
compactView animal =
  div [] []
--   let
--     animal = displayedAnimal.animal
--     flash = displayedAnimal.animalFlash
--   in
--     tr []
--       [ (td []
--            [ p [] ( animalSalutation animal  :: animalTags animal)
--            , AnimalFlash.showWithButton flash (WithAnimal displayedAnimal RemoveFlash)
--            ])
--       , Icon.expand displayedAnimal Bulma.tdIcon
--       , Icon.edit displayedAnimal Bulma.tdIcon
--       , Icon.moreLikeThis displayedAnimal Bulma.tdIcon
--       ]

expandedView : Animal -> Html Msg      
expandedView animal =
  div [] []
--   let
--     animal = displayedAnimal.animal
--     flash = displayedAnimal.animalFlash
--   in
--     Bulma.highlightedRow []
--       [ td []
--           [ p [] [ animalSalutation animal ]
--           , p [] (animalTags animal)
--           , animalProperties animal |> Bulma.propertyTable
--           , AnimalFlash.showWithButton flash (WithAnimal displayedAnimal RemoveFlash)
--           ]
--       , Icon.contract displayedAnimal Bulma.tdIcon
--       , Icon.edit displayedAnimal Bulma.tdIcon
--       , Icon.moreLikeThis displayedAnimal Bulma.tdIcon
--       ]
      
-- -- Util

-- animalProperties : Animal -> List (Html msg)
-- animalProperties animal =
--   let
--     row (key, value) = 
--       tr []
--         [ td [] [text key]
--         , td [] (propertyDisplayValue value)
--         ]
--     propertyPairs = Dict.toList (animal.properties)
--   in
--       List.map row propertyPairs

-- propertyDisplayValue : DictValue -> List (Html msg)
-- propertyDisplayValue value =     
--   case value of
--     AsBool b m -> boolExplanation b m
--     AsString s _ -> [text s]
--     _ -> [text "unimplemented"]

-- boolExplanation : Bool -> String -> List (Html msg)
-- boolExplanation b explanation = 
--   let
--     icon = case b of
--              True -> Bulma.trueIcon
--              False -> Bulma.falseIcon
--     suffix = case explanation of
--                "" -> ""
--                s -> " (" ++ s ++ ")"
--   in
--     [icon, text suffix]



-- animalSalutation : Animal -> Html msg
-- animalSalutation animal =
--   text <| animal.name ++ (parentheticalSpecies animal)

-- animalTags : Animal -> List (Html Msg)
-- animalTags animal =
--   List.map Bulma.readOnlyTag animal.tags

-- parentheticalSpecies : Animal -> String
-- parentheticalSpecies animal =
--   " (" ++ animal.species ++ ")"


