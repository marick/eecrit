module Pile.Calendar exposing
  ( DisplayDate(..)
  , DateHolder
  , view

  , enhancedDateString -- TEMP
    
  , startingState
  , choose
    
  , dateHolder_chosen
  , dateHolder_todayForReference
  , dateHolder_datePickerOpen
  )

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Date
import Date.Extra as Date
import DateSelector

import Pile.UpdatingLens exposing (UpdatingLens, lens)
import Pile.UpdatingOptional exposing (UpdatingOptional, opt)


-- TODO: switch to Html.map with 0.18
import VirtualDom

type DisplayDate 
  = Today
  | At Date.Date


type alias DateHolder =
  { chosen : DisplayDate
  , todayForReference : Maybe Date.Date
  , datePickerOpen : Bool
  }

dateHolder_chosen : UpdatingLens DateHolder DisplayDate
dateHolder_chosen = lens .chosen (\ p w -> { w | chosen = p })

dateHolder_todayForReference : UpdatingOptional DateHolder Date.Date
dateHolder_todayForReference =
  opt .todayForReference (\ p w -> { w | todayForReference = Just p })

dateHolder_datePickerOpen : UpdatingLens DateHolder Bool
dateHolder_datePickerOpen = lens .datePickerOpen (\ p w -> { w | datePickerOpen = p })

startingState : DateHolder
startingState = 
  { chosen = Today
  , todayForReference = Nothing -- It needs to be fetched from outside world
  , datePickerOpen = False
  }

-- If the chosen date is today, so note.
choose : Date.Date -> DateHolder -> DateHolder
choose date holder =
  let 
    displayDate =
      case Maybe.map (Date.equalBy Date.Day date) holder.todayForReference of
        Just True -> Today
        _ -> At date
  in 
     dateHolder_chosen.set displayDate holder
  
type alias Launcher msg =
  Bool -> String -> msg -> Html msg

view : Launcher msg -> msg -> (Date.Date -> msg) -> DateHolder -> Html msg

view launcher calendarToggleMsg dateSelectedMsg holder =
  let
    min = (bound (-) holder)
    max = (bound (+) holder)
    selected = dateToShow holder
    calendarBodyView =
      if holder.datePickerOpen then
        Just (DateSelector.view min max selected |> VirtualDom.map dateSelectedMsg)
      else
        Nothing
  in
    visibilityController
      calendarToggleMsg
      (launcher holder.datePickerOpen (enhancedDateString holder) calendarToggleMsg)
      calendarBodyView

  
enhancedDateString : DateHolder -> String
enhancedDateString holder =
  let
    todayIfKnown =
      case holder.todayForReference of
        Nothing ->
          ""
        Just date ->
          Date.toFormattedString " (MMM d)" date
  in
    case holder.chosen of
      Today -> 
        "Today" ++ todayIfKnown
      At date ->
        Date.toFormattedString "MMM d, y" date

          
dateToShow : DateHolder -> Maybe Date.Date
dateToShow holder =
  case holder.chosen of 
    Today -> holder.todayForReference
    At date -> Just date

defaultDate : Date.Date
defaultDate = Date.fromCalendarDate 2018 Date.Jan 1

bound : (number -> number -> Int) -> DateHolder -> Date.Date
bound shiftFunction holder =
  let
    shiftByYears date =
      Date.add Date.Year (shiftFunction 0 5) date
  in
    case dateToShow holder of
      Nothing -> shiftByYears defaultDate
      Just date -> shiftByYears date

visibilityController : msg -> Html msg -> Maybe (Html msg) -> Html msg
visibilityController calendarToggleMsg control maybeContent =
  let
    controlContainer =
      div
        [ class "dropdown--button-container" ]
        [ control ]
  in
    case maybeContent of
      Nothing ->
        div
          [ class "dropdown" ]
          [ controlContainer ]

      Just content ->
        div
          [ class "dropdown-open" ]
          [ div
              [ class "dropdown--page-cover"
              , onClick calendarToggleMsg
              ]
              []
          , controlContainer
          , div
              [ class "dropdown--content-container" ]
              [ content ]
          ]
