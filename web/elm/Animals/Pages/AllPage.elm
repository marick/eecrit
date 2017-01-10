module Animals.Pages.AllPage exposing (..)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Set exposing (Set)

import Pile.Bulma as Bulma
import Pile.Namelike as Namelike
import Pile.Calendar as Calendar

import Animals.Model exposing (Model)

import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Form as Form
import Animals.Msg exposing (..)

import Animals.Animal.FormView as FormView
import Animals.Animal.AnimalView as AnimalView

-- Delete thest 
import Animals.Animal.ReadOnlyViews as RO
import Animals.Animal.EditableView as RW
import Animals.Pages.PageFlash as PageFlash


view : Model -> Html Msg
view model =
  div []
    [ filterView model
    , PageFlash.show model.pageFlash
    , Bulma.headerlessTable <| animalViews model
    ]

animalViews : Model -> List (Html Msg)    
animalViews model =
  let
    displayed = pageAnimals_v2 .allPageAnimals model
    animalViewer = individualAnimalView_v2 model (StartSavingEdits, CancelEdits)
  in
    displayed
      |> applyFilters model
      |> List.map animalViewer


pageAnimals_v2 : (Model -> Set Id) -> Model -> List Displayed
pageAnimals_v2 pageAnimalsGetter model =
  model
    |> pageAnimalsGetter
    |> Set.toList 
    |> List.map (\ id -> Dict.get id model.displayables)
    |> List.filterMap identity

individualAnimalView_v2 : Model -> (FormOperation, FormOperation) -> Displayed
                     -> Html Msg
individualAnimalView_v2 model formActions displayed =
  case displayed.view of
    Writable form ->
      FormView.view form displayed.animalFlash formActions 
    Viewable animal ->
      case animal.displayFormat of
        Compact ->
          AnimalView.compactView animal displayed.animalFlash
        Expanded ->
          AnimalView.expandedView animal displayed.animalFlash
        Editable -> --- TODO: this will be deleted
          AnimalView.expandedView animal displayed.animalFlash

         
filterView : Model -> Html Msg
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

pageAnimals : (Model -> Set Id) -> Model -> List DisplayedAnimal
pageAnimals pageAnimalsGetter model =
  model
    |> pageAnimalsGetter
    |> Set.toList 
    |> List.map (\ animal -> Dict.get animal model.animals)
    |> List.filterMap identity


applyFilters : Model -> List Displayed -> List Displayed
applyFilters model xs = 
  let
    rightSpecies =
      displayed_species.get >> Namelike.isPrefix model.speciesFilter

    rightName = 
      displayed_name.get >> Namelike.isPrefix model.nameFilter
        
    rightTag =
      displayed_tags.get >> Namelike.isTagListAllowed model.tagFilter
  in
    xs
      |> List.filter (aggregateFilter [rightSpecies, rightName, rightTag])
      |> Namelike.sortByName displayed_name.get


aggregateFilter : List (Displayed -> Bool) -> Displayed -> Bool
aggregateFilter preds animal =
  case preds of
    [] ->
      True
    p :: ps ->
      if (p animal) then
        aggregateFilter ps animal
      else
        False

individualAnimalView : Model -> (FormOperation, FormOperation) -> DisplayedAnimal
                     -> Html Msg
individualAnimalView model formActions displayedAnimal  =
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
        RW.editableView displayedAnimal form formActions 

animalForm : Model -> Animal -> Form
animalForm model animal =
  Dict.get animal.id model.forms
    |> Maybe.withDefault Form.nullForm -- impossible case


-- The calendar

dateControl : Bool -> String -> msg -> Html msg
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

nameFilter : Model -> Html Msg
nameFilter model =
  Bulma.centeredLevelItem
    [ Bulma.headingP "Name"
    , Bulma.simpleTextInput model.nameFilter SetNameFilter
    ]

tagsFilter : Model -> Html Msg
tagsFilter model =
  Bulma.centeredLevelItem
    [ Bulma.headingP "Tag"
    , Bulma.simpleTextInput model.tagFilter SetTagFilter
    ]

speciesFilter : Model -> Html Msg
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
    
calendarHelp : Bulma.IconExpander Msg -> Html Msg
calendarHelp iconType = 
  iconType "fa-question-circle" "Help on animals and dates" NoOp

filterHelp : Bulma.IconExpander Msg -> Html Msg
filterHelp iconType = 
  iconType "fa-question-circle" "Help on filtering" NoOp    

