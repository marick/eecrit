module Animals.View.AllPageView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.HtmlShorthand exposing (..)
import Html.Events as Events
import Pile.Bulma as Bulma 
import Pile.Calendar as Calendar
import Animals.Main as Main exposing (DisplayState(..), Msg(..))


view model =
  div []
    [ Bulma.centeredColumns
        [ Bulma.column 4
            [ Bulma.messageView
                [ text "Animals as of..."
                , calendarHelp Bulma.rightIcon
                ]
                [ Calendar.view dateControl ToggleDatePicker SelectDate model
                ] 
            ]                  
        , Bulma.column 7
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
    tr [ style [ ("border-top", "2px solid")
               , ("border-bottom", "2px solid")
               ]
       ]
      [ td []
          [ p [] [ animalSalutation animal ]
          , p [] (animalTags animal)
          , p [] [text <| "Added " ++ animal.dateAcquired]
          ]
      , contract animal Bulma.tdIcon
      , edit animal Bulma.tdIcon
      , moreLikeThis animal Bulma.tdIcon
      ]
      
animalViewEditable animal =
  tr [] [ text "editable" ] 


animalSalutation animal =
  text <| animal.name ++ " (" ++ animal.species ++ ")"

animalTags animal =
  List.map Bulma.oneTag animal.tags


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
