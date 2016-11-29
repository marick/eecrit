module Animals.View.AllPageView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.HtmlShorthand exposing (..)
import Html.Events as Events
import Pile.Bulma as Bulma
import String
import List
import Animals.Main exposing (DisplayState(..), Msg(..), desiredAnimals, EffectiveDate(..))
import Date exposing (Month(..))
import Date.Extra exposing (toFormattedString, fromCalendarDate, fromParts, Interval(..))
import DateSelectorDropdown


shiftByYears shiftFunction date =
  Date.Extra.add Year (shiftFunction 0 5) date

bound shiftFunction model =
  case showDate model of
    Nothing -> shiftByYears shiftFunction (fromCalendarDate 2018 Jan 1)
    Just date -> shiftByYears shiftFunction date

showDate model =
  case model.effectiveDate of 
    Today -> model.today
    At date -> Just date
  

view model =
  div []
    [
     DateSelectorDropdown.view
       ToggleDatePicker
       SelectDate
       model.datePickerOpen
       (bound (-) model)
       (bound (+) model)
       (showDate model)

    , div [class "columns is-centered"]
        [ div [class "column is-4"]

          [ messageView model
              [ text "Animals as of..."
              , rightIcon "fa-question-circle" "Help on animals and dates" NoOp
              ]
              [ p [class "has-text-centered"]
                  [ text (effectiveDateString model)
                  , plainIcon "fa-caret-down" "Pick a date from a calendar" ToggleDatePicker
                  ]
              ]
          ]                  
            
        , div [class "column is-7"]
          [ messageView model 
             [ text "Filter by..."
             , rightIcon "fa-question-circle" "Help on filtering" NoOp
             ]
             (filterFields model)
          ]
        ]
    , animalList model 
    ]

standardDate date =
  toFormattedString "MM d, y" date

    
effectiveDateString model =
  let
    todayIfKnown =
      case model.today of
        Nothing ->
          ""
        Just date ->
          toFormattedString " (MMM d)" date
  in
    case model.effectiveDate of
      Today -> 
        "Today" ++ todayIfKnown
      At date ->
        toFormattedString "MMM d, y" date

animalList model = 
  table [class "table"]
    [ tbody []
        (List.map oneAnimal (desiredAnimals model))
    ]

oneAnimal animal =
  case animal.displayState of
    Compact -> oneAnimalCompact animal
    Expanded -> oneAnimalExpanded animal
    Editable -> oneAnimalEditable animal

animalSalutation animal =
  text <| animal.name ++ " (" ++ animal.species ++ ")"

animalTags animal =
  List.map oneTag animal.tags
                
oneAnimalCompact animal = 
    tr []
      [ (td [] [ p [] ( animalSalutation animal  :: animalTags animal)])
      , expand animal
      , edit animal
      , moreLikeThis animal
      ]

oneAnimalExpanded animal =
    tr [ style [ ("border-top", "2px solid")
               , ("border-bottom", "2px solid")
               ]
       ]
      [ td []
          [ p [] [ animalSalutation animal ]
          , p [] (animalTags animal)
          , p [] [text <| "Added " ++ animal.dateAcquired]
          ]
      , contract animal
      , edit animal
      , moreLikeThis animal
      ]
      

oneAnimalEditable animal =
  tr [] [ text "editable" ] 

tdIcon iconSymbolName tooltip msg =
  td [class "is-icon"]
    [a [ href "#"
       , title tooltip
       , onClickWithoutPropagation msg
       ]
       [i [class ("fa " ++ iconSymbolName)] []]
    ]

plainIcon iconSymbolName tooltip msg =
  a [ href "#"
    , class "icon"
    , title tooltip
    , onClickWithoutPropagation msg
    ]
    [i [class ("fa " ++ iconSymbolName)] []]

    
rightIcon iconSymbolName tooltip msg =
  a [ href "#"
    , class "icon is-pulled-right"
    , title tooltip
    , onClickWithoutPropagation msg
    ]
    [i [class ("fa " ++ iconSymbolName)] []]

expand animal =
  tdIcon "fa-caret-down"
    "Expand: show more about this animal"
    (ExpandAnimal animal.id)
      
contract animal =
  tdIcon "fa-caret-up"
    "Expand: show less about this animal"
    (ContractAnimal animal.id)
      
edit animal =
  tdIcon "fa-pencil"
    "Edit: make changes to this animal"
    (EditAnimal animal.id)
      
moreLikeThis animal =
  tdIcon "fa-plus"
    "Copy: make more animals like this one"
    (MoreLikeThisAnimal animal.id)
      
oneTag tagText =
  span [ class "tag" ] [ text tagText ]
    
messageView model headerList contentList  =
  article [class "message"]
    [ div [class "message-header has-text-centered"] headerList
    , div [class "message-body"] contentList
    ]

filterFields model =
  [ div [class "level"]
      [ nameField model
      , speciesField model
      , tagsField model 
      ]
  ]


nameField model =
  centeredLevelItem
    [ headingP "Name"
    , textInput model.nameFilter SetNameFilter
    ]

tagsField model =
  centeredLevelItem
  [ headingP "Tag"
  , textInput model.tagFilter SetTagFilter
  ]

speciesField model =
  centeredLevelItem
  [ p [class "heading"] [ text "Species" ]
  , standardSelect
      [ textOption "" "Any"
      , textOption "bovine" "bovine"
      , textOption "equine" "equine"
      ]
  ]

centeredLevelItem content =
  div [class "level-item has-text-centered"]
    content

standardSelect content = 
  span [ class "select" ]
    [ select [] content ]

textOption val display = 
  option
    [ value val
    , Events.onClick (SetSpeciesFilter val)
    ]
    [ text display ]

headingP heading = 
  p [class "heading"] [text heading]

textInput val msg = 
  p [class "control"]
    [input
       [ class "input"
       , type' "text"
       , value val
       , Events.onInput msg]
       []
    ]
