module Animals.Pages.AllPage exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Set
import String
import String.Extra as String

import Pile.Bulma as Bulma
import Pile.Namelike as Namelike
import Pile.Calendar as Calendar
import Pile.HtmlShorthand exposing (..)

import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Form as Form
import Animals.Msg exposing (..)
import Animals.Animal.ReadOnlyViews as RO
import Animals.Animal.EditableView as RW
import Animals.Pages.PageFlash as PageFlash


view model =
  div []
    [ filterView model
    , PageFlash.show model.pageFlash
    , Bulma.headerlessTable <| animalViews model
    ]
    
animalViews model =
  model
    |> allPageAnimals
    |> applyFilters model
    |> List.map (individualAnimalView model)
    
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

allPageAnimals model =
  model.allPageAnimals
    |> Set.toList 
    |> List.map (\ animal -> Dict.get animal model.animals)
    |> List.filterMap identity

applyFilters model animals = 
  let
    rightSpecies displayed =
      Namelike.isPrefix model.speciesFilter displayed.animal.species

    rightName displayed =
      Namelike.isPrefix model.nameFilter displayed.animal.name

    rightTag displayed =
      Namelike.isBlank model.tagFilter || 
        List.any (Namelike.isPrefix model.tagFilter) displayed.animal.tags
  in
    animals
      |> List.filter (aggregateFilter [rightSpecies, rightName, rightTag])
      |> Namelike.sortByName displayedAnimal_name.get


aggregateFilter preds animal =
  case preds of
    [] ->
      True
    p :: ps ->
      if (p animal) then
        aggregateFilter ps animal
      else
        False
         
individualAnimalView model displayedAnimal =
  case displayedAnimal.format of
    Compact ->
      RO.compactView displayedAnimal
    Expanded ->
      RO.expandedView displayedAnimal
    Editable ->
      let
        -- Todo: animalForm currently produces an empty form for the
        -- "impossible" case of no form corresponding to the being-edited
        -- animal. Replace that with an an error message.
        form = animalForm model displayedAnimal.animal
      in
        RW.editableView displayedAnimal form (StartSavingEdits, CancelEdits)

animalForm model animal =
  Dict.get animal.id model.forms
    |> Maybe.withDefault Form.nullForm -- impossible case


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

