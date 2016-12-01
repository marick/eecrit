module Animals.View.AllPageView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.HtmlShorthand exposing (..)
import Html.Events as Events
import Pile.Bulma as Bulma 
import Pile.Calendar as Calendar
import Animals.Main as Main exposing (DisplayState(..), Msg(..), DictValue(..))
import List
import Dict
import String.Extra exposing (toSentenceCase)

view model =
  div []
    [ Bulma.centeredColumns
        [ Bulma.column 3
            [ Bulma.messageView
                [ text "Animals as of..."
                , calendarHelp Bulma.rightIcon
                ]
                [ Calendar.view dateControl ToggleDatePicker SelectDate model
                ] 
            ]                  
        , Bulma.column 8
            [ Bulma.messageView 
                [ text "Filter by..."
                , filterHelp Bulma.rightIcon
                ]
                [ Bulma.distributeHorizontally
                    [ nameFilter model
                    , speciesFilter model
                    , tagsFilter model 
                    ]
                ]
            ]
        ]
    , Main.filteredAnimals model |> List.map animalView |> Bulma.headerlessTable 
    ]
    
-- The calendar

dateControl hasOpenPicker displayString calendarToggleMsg =
  let
    iconF =
      case hasOpenPicker of
        False -> Bulma.plainIcon "fa-caret-down" "Pick a date from a calendar" 
        True -> Bulma.plainIcon "fa-caret-up" "Close the calendar"
  in
    p [class "has-text-centered"]
      [ text displayString
      , iconF calendarToggleMsg
      ]

-- Filters

nameFilter model =
  Bulma.centeredLevelItem
    [ Bulma.headingP "Name"
    , Bulma.simpleTextInput model.nameFilter SetNameFilter
    ]

tagsFilter model =
  Bulma.centeredLevelItem
    [ Bulma.headingP "Tag"
    , Bulma.simpleTextInput model.tagFilter SetTagFilter
    ]

speciesFilter model =
  let 
    textOption val display = 
      option
      [ value val
      , Events.onClick (SetSpeciesFilter val)
      ]
      [ text display ]
  in
    Bulma.centeredLevelItem
      [ Bulma.headingP "Species" 
      , Bulma.simpleSelect
        [ textOption "" "Any"
        , textOption "bovine" "bovine"
        , textOption "equine" "equine"
        ]
      ]
      

-- The animals


animalView animal =
  case animal.displayState of
    Compact -> animalViewCompact animal
    Expanded -> animalViewExpanded animal
    Editable -> animalViewEditable animal

animalViewCompact animal = 
    tr []
      [ (td [] [ p [] ( animalSalutation animal  :: animalTags animal)])
      , expand animal Bulma.tdIcon
      , edit animal Bulma.tdIcon
      , moreLikeThis animal Bulma.tdIcon
      ]

animalViewExpanded animal =
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

editableName animal =
  case animal.editableCopy of
    Nothing ->
      ""
    Just editable ->
      editable.name
    
animalViewEditable animal =
  tr [ emphasizeBorder ]
    [ td []
        [ div [class "control is-horizontal"]
            [ div [class "control-label"] [label [class "label"] [text "Name"]]
            , div [class "control is-grouped"]
              [ p [class "control"]
                  [ input [ class "input"
                          , type' "text"
                          , value (editableName animal)
                          , Events.onInput (SetEditedName animal.id)
                          ] []
                  ]
              ]
            ]
        , div [class "control is-horizontal"]
            [ div [class "control-label"] [label [class "label"] [text "Tags"]]
            , p [class "control is-grouped"]
              (List.map Bulma.deletableTag animal.tags)
            ]

        , p []
          [ a [ class "button is-success pull-left"
              , onClickWithoutPropagation (SaveAnimalEdit animal.id)
              ]
              [ span [class "icon"] [i [class "fa fa-check"] []]
              , text "Save"
              ]
          ]

        , p []
          [ a [ class "button is-danger pull-right"
              , onClickWithoutPropagation (CancelAnimalEdit animal.id)
              ]
              [ span [class "icon"] [i [class "fa fa-times"] []]
              , text "Cancel"
              ]
          ]
        ]
    , td [] []
    , td [] []
    , editHelp Bulma.tdIcon
    ]
    
emphasizeBorder =
  style [ ("border-top", "2px solid")
        , ("border-bottom", "2px solid")
        ]
    
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
      
animalProperties animal =
  let
    explanation value =
      case value of
        Nothing -> [span [style [("color", "red")]] [text "unknown"]]
        Just (AsBool b m) -> boolExplanation b m
        Just (AsString s) -> [text s]
        _ -> [text "unimplemented"]

    row key = 
      tr []
        [ td [] [text key]
        , td [] (Dict.get key animal.properties |> explanation)
        ]
  in  
    List.map row ["Available", "Primary billing"]

parentheticalSpecies animal =
  " (" ++ animal.species ++ ")"

animalSalutation animal =
  text <| (toSentenceCase animal.name) ++ (parentheticalSpecies animal)

animalTags animal =
  List.map Bulma.readOnlyTag animal.tags


-- Various icons
    
expand animal iconType =
  iconType "fa-caret-down"
    "Expand: show more about this animal"
    (ExpandAnimal animal.id)
      
contract animal iconType =
  iconType "fa-caret-up"
    "Expand: show less about this animal"
    (ContractAnimal animal.id)
      
edit animal iconType =
  iconType "fa-pencil"
    "Edit: make changes to this animal"
    (EditAnimal animal.id)
      
moreLikeThis animal iconType =
  iconType "fa-plus"
    "Copy: make more animals like this one"
    (MoreLikeThisAnimal animal.id)
      
calendarHelp iconType = 
  iconType "fa-question-circle" "Help on animals and dates" NoOp

filterHelp iconType = 
  iconType "fa-question-circle" "Help on filtering" NoOp    

editHelp iconType = 
  iconType "fa-question-circle" "Help on editing" NoOp    
    
