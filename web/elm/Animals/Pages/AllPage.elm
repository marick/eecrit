module Animals.Pages.AllPage exposing (view)

import Animals.Pages.Common as Common
import Animals.View.PageFlash as PageFlash

import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Msg exposing (..)
import Animals.Model exposing (Model)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.Css.Bulma as Css
import Pile.Namelike as Namelike exposing (Namelike)
import Pile.Calendar as Calendar

view : Model -> Html Msg
view model =
  div []
    [ filterView model
    , PageFlash.show model.pageFlash
    , Css.headerlessTable <| animalViews model
    ]

animalViews : Model -> List (Html Msg)    
animalViews model =
  let
    displayed = Common.pageAnimals .allPageAnimals model
    animalViewer = Common.individualAnimalView model (StartSavingEdits, CancelEdits)
  in
    displayed
      |> applyFilters model
      |> List.map animalViewer


filterView : Model -> Html Msg
filterView model =
  Css.centeredColumns
    [ Css.column 3
        [ Css.messageView
            [ text "Animals as of..."
            , calendarHelp Css.rightIcon
            ]
            [ Calendar.view dateControl ToggleDatePicker SelectDate model
            ] 
        ]                  
    , Css.column 8
      [ Css.messageView 
          [ text "Filter by..."
          , filterHelp Css.rightIcon
          ]
          [ Css.distributeHorizontally
              [ nameFilter model
              , speciesFilter model
              , tagsFilter model 
              ]
          ]
      ]
    ]

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
      |> Namelike.sortByName displaySortKey

displaySortKey : Displayed -> Namelike
displaySortKey displayed =
  case displayed.view of
    Writable form -> form.sortKey
    Viewable animal -> animal.name 

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


-- -- The calendar

dateControl : Bool -> String -> msg -> Html msg
dateControl hasOpenPicker displayString calendarToggleMsg =
  let
    iconF =
      case hasOpenPicker of
        False -> Css.plainIcon "fa-caret-down" "Pick a date from a calendar" 
        True -> Css.plainIcon "fa-caret-up" "Close the calendar"
  in
    p [class "has-text-centered"]
      [ text displayString
      , iconF calendarToggleMsg
      ]

-- -- Filters

nameFilter : Model -> Html Msg
nameFilter model =
  Css.centeredLevelItem
    [ Css.headingP "Name"
    , Css.simpleTextInput model.nameFilter SetNameFilter
    ]

tagsFilter : Model -> Html Msg
tagsFilter model =
  Css.centeredLevelItem
    [ Css.headingP "Tag"
    , Css.simpleTextInput model.tagFilter SetTagFilter
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
    Css.centeredLevelItem
      [ Css.headingP "Species" 
      , Css.simpleSelect
        [ textOption "" "Any"
        , textOption "bovine" "bovine"
        , textOption "equine" "equine"
        ]
      ]
      


-- -- Various icons
    
calendarHelp : Css.IconExpander Msg -> Html Msg
calendarHelp iconType = 
  iconType "fa-question-circle" "Help on animals and dates" NoOp

filterHelp : Css.IconExpander Msg -> Html Msg
filterHelp iconType = 
  iconType "fa-question-circle" "Help on filtering" NoOp    

