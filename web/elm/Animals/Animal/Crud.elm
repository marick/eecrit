module Animals.Animal.Crud exposing (..)
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
import Animals.Msg exposing (..)
import Animals.Animal.Edit exposing (..)


applyEdits animal form =
  case updateAnimal animal form of
    Ok newAnimal ->
      UpsertExpandedAnimal newAnimal NoFlash
    Err (newAnimal, flash) ->
      UpsertExpandedAnimal newAnimal flash

-- Note that this cancels the flash        
showFlash : Flash -> (Flash -> Msg) -> Html Msg
showFlash flash partialMsg =
  case flash of 
    NoFlash -> 
      span [] []
    SavedIncompleteTag tagName -> 
      Bulma.flashNotification (partialMsg NoFlash)
        [ text "Excuse my presumption, but I notice you clicked "
        , Bulma.exampleSuccess
        , text " while there was text in the "
        , b [] [text "New Tag"]
        , text " field. So I've added the tag "
        , Bulma.readOnlyTag tagName
        , text " for you."
        , text " You can delete it if I goofed."
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


-- Various icons

expand animal iconType =
  iconType "fa-caret-down"
    "Expand: show more about this animal"
    (UpsertExpandedAnimal animal NoFlash)
      
contract animal iconType =
  iconType "fa-caret-up"
    "Expand: show less about this animal"
    (UpsertCompactAnimal animal NoFlash)
      
edit animal iconType =
  iconType "fa-pencil"
    "Edit: make changes to this animal"
    (beginEditing animal)
      
moreLikeThis animal iconType =
  iconType "fa-plus"
    "Copy: make more animals like this one"
    (MoreLikeThisAnimal animal.id)

editHelp iconType = 
  iconType "fa-question-circle" "Help on editing" NoOp    
      
