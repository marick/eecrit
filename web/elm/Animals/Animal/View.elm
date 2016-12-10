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

import Animals.Animal.Model exposing (..)
import Animals.Msg exposing (..)
import Animals.Animal.Edit exposing (..)

view {animal, display, flash} =
  case display of
    Compact -> compactView animal flash
    Expanded -> expandedView animal flash
    Editable changing -> editableView animal changing flash

compactView animal flash =
  tr []
    [ (td []
         [ p [] ( animalSalutation animal  :: animalTags animal)
         , showFlash flash (cancelFlash animal Compact)
         ])
    , expand animal Bulma.tdIcon
    , edit animal Bulma.tdIcon
    , moreLikeThis animal Bulma.tdIcon
    ]

expandedView animal flash =
  Bulma.highlightedRow []
    [ td []
        [ p [] [ animalSalutation animal ]
        , p [] (animalTags animal)
        , animalProperties animal |> Bulma.propertyTable
        , showFlash flash (cancelFlash animal Expanded)
        ]
    , contract animal Bulma.tdIcon
    , edit animal Bulma.tdIcon
    , moreLikeThis animal Bulma.tdIcon
    ]

editableView animal form flash =
  Bulma.highlightedRow []
    [ td []
        [ Bulma.controlRow "Name" <| nameEditControl animal form
        , Bulma.controlRow "Tags" <| deleteTagControl animal form
        , Bulma.controlRow "New Tag" <| newTagControl animal form
            
        -- , Bulma.controlRow "Properties"
        --     <| Bulma.oneReasonablySizedControl
        --          (editableAnimalProperties form |> Bulma.propertyTable)

        , Bulma.leftwardSuccess (isSafeToSave form) (applyEdits animal form)
        , Bulma.rightwardCancel (reviseDisplay animal Expanded)
        , showFlash flash (cancelFlash animal (Editable form))
        ]
    , td [] []
    , td [] []
    , editHelp Bulma.tdIcon
    ]

applyEdits animal form =
  case updateAnimal animal form of
    Ok newAnimal ->
      reviseDisplay newAnimal Expanded
    Err (newAnimal, flash) -> 
      displayWithFlash newAnimal Expanded flash
    
showFlash : Flash -> Msg -> Html Msg
showFlash flash msg =
  case flash of 
    NoFlash -> 
      span [] []
    SavedIncompleteTag tagName -> 
      Bulma.flashNotification msg
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
    (reviseDisplay animal Expanded)
      
contract animal iconType =
  iconType "fa-caret-up"
    "Expand: show less about this animal"
    (reviseDisplay animal Compact)
      
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
      
