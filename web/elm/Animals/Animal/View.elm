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

view {animal, display, warning} =
  case display of
    Compact -> compactView animal warning
    Expanded -> expandedView animal warning
    Editable changing -> editableView animal changing warning

compactView animal warning =
  tr []
    [ (td []
         [ p [] ( animalSalutation animal  :: animalTags animal)
         , showWarning warning (cancelFlash animal Compact)
         ])
    , expand animal Bulma.tdIcon
    , edit animal Bulma.tdIcon
    , moreLikeThis animal Bulma.tdIcon
    ]

expandedView animal warning =
  Bulma.highlightedRow []
    [ td []
        [ p [] [ animalSalutation animal ]
        , p [] (animalTags animal)
        , animalProperties animal |> Bulma.propertyTable
        , showWarning warning (cancelFlash animal Expanded)
        ]
    , contract animal Bulma.tdIcon
    , edit animal Bulma.tdIcon
    , moreLikeThis animal Bulma.tdIcon
    ]

editableView animal changes warning =
  Bulma.highlightedRow []
    [ td []
        [ Bulma.controlRow "Name" <| nameEditControl animal changes
        , Bulma.controlRow "Tags" <| deleteTagControl animal changes
        , Bulma.controlRow "New Tag" <| newTagControl animal changes
            
        -- , Bulma.controlRow "Properties"
        --     <| Bulma.oneReasonablySizedControl
        --          (editableAnimalProperties changes |> Bulma.propertyTable)

        , Bulma.leftwardSuccess (applyEdits animal changes)
        , Bulma.rightwardCancel (reviseDisplay animal Expanded)
        , showWarning warning (cancelFlash animal (Editable changes))
        ]
    , td [] []
    , td [] []
    , editHelp Bulma.tdIcon
    ]

applyEdits animal form =
  let
    (newAnimal, warning) = updateAnimal animal form
  in
    displayWithFlash newAnimal Expanded warning
    
showWarning : Warning -> Msg -> Html Msg
showWarning warning msg =
  case warning of 
    AllGood -> 
      span [] []
    AutoSavedTagWarning tagName -> 
      Bulma.warningNotification msg
        [ text "You saved without adding the unfinished "
        , Bulma.readOnlyTag tagName
        , text " tag, so I added it for you. Sorry if that wasn't what you wanted. "
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
      
