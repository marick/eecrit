module Animals.Pages.AllPage exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Set
import String
import String.Extra as String

import Pile.Bulma as Bulma 
import Pile.Calendar as Calendar
import Pile.HtmlShorthand exposing (..)

import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Msg exposing (..)
import Animals.Animal.ReadOnlyViews as RO
import Animals.Animal.EditableView as RW
import Animals.Pages.PageFlash as PageFlash

view model =
  let
    validationContext = calculateValidationContext model
    whichToShow = filteredAnimals model |> contextualize validationContext
  in
    div []
      [ filterView model
      , PageFlash.show model.pageFlash
      , Bulma.headerlessTable whichToShow
      ]

filterView model =
  Bulma.centeredColumns
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

contextualize context animals =
  List.map (individualAnimalView context) animals

filteredAnimals model = 
  let
    hasWanted modelFilter animalValue =
      let 
        wanted = model |> modelFilter |> String.toLower
        has = animalValue |> String.toLower
      in
        String.startsWith wanted has

    hasDesiredSpecies displayed = hasWanted .speciesFilter displayed.animal.species
    hasDesiredName displayed = hasWanted .nameFilter displayed.animal.name
    hasDesiredTag displayed =
      String.isEmpty model.tagFilter || 
        List.any (hasWanted .tagFilter) displayed.animal.tags
  in
    animalsToDisplay model
      [displayedAnimal_wasEverSaved.get, hasDesiredSpecies, hasDesiredName, hasDesiredTag]


animalsToDisplay model filters = 
    model.animals
      |> Dict.values
      |> List.filter (aggregateFilter filters)
      |> humanSorted
         
aggregateFilter preds animal =
  case preds of
    [] ->
      True
    p :: ps ->
      if (p animal) then
        aggregateFilter ps animal
      else
        False
         
humanSorted animals = 
  List.sortBy (.animal >> .name >> String.toLower) animals

individualAnimalView validationContext {animal, display, flash} =
  case display of
    Compact -> RO.compactView animal flash
    Expanded -> RO.expandedView animal flash
    Editable changing -> RW.view validationContext animal changing flash

calculateValidationContext model =
  { allAnimalNames =
      model.animals |> Dict.values |> List.map displayedAnimal_name.get |> Set.fromList
  }

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
      


-- Various icons
    
      
calendarHelp iconType = 
  iconType "fa-question-circle" "Help on animals and dates" NoOp

filterHelp iconType = 
  iconType "fa-question-circle" "Help on filtering" NoOp    

