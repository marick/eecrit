module Pile.Calendar exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Date exposing (Date, Month(..))
import Date.Extra
import DateSelectorDropdown


type EffectiveDate 
  = Today
  | At Date.Date

type alias CalendarDate =
  { effectiveDate : EffectiveDate
  , today : Maybe Date
  , datePickerOpen : Bool
  }

view launcher calendarToggleMsg dateSelectedMsg edate =
  DateSelectorDropdown.viewWithButton
    launcher
    calendarToggleMsg
    dateSelectedMsg
    edate.datePickerOpen
    (bound (-) edate)
    (bound (+) edate)
    (dateToShow edate)

  
enhancedDateString : CalendarDate -> String   
enhancedDateString edate =
  let
    todayIfKnown =
      case edate.today of
        Nothing ->
          ""
        Just date ->
          Date.Extra.toFormattedString " (MMM d)" date
  in
    case edate.effectiveDate of
      Today -> 
        "Today" ++ todayIfKnown
      At date ->
        Date.Extra.toFormattedString "MMM d, y" date

dateToShow edate =
  case edate.effectiveDate of 
    Today -> edate.today
    At date -> Just date


shiftByYears shiftFunction date =
  Date.Extra.add Date.Extra.Year (shiftFunction 0 5) date

bound shiftFunction edate =
  case dateToShow edate of
    Nothing -> shiftByYears shiftFunction (Date.Extra.fromCalendarDate 2018 Jan 1)
    Just date -> shiftByYears shiftFunction date

skeleton : msg -> Html msg -> Maybe (Html msg) -> Html msg
skeleton close control maybeContent =
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
              , onClick close
              ]
              []
          , controlContainer
          , div
              [ class "dropdown--content-container" ]
              [ content ]
          ]


standardDate date =
  Date.Extra.toFormattedString "MM d, y" date

    
formatDate date =
  case date of
    Nothing -> ""
    Just d -> Date.Extra.toFormattedString "MMM d, y" d

          
