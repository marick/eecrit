module Pile.Calendar exposing (EffectiveDate(..), view)

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Date exposing (Date, Month(..))
import Date.Extra
import DateSelector

-- TODO: switch to Html.map with 0.18
import VirtualDom

type EffectiveDate 
  = Today
  | At Date.Date

view launcher calendarToggleMsg dateSelectedMsg edate =
  let
    min = (bound (-) edate)
    max = (bound (+) edate)
    selected = dateToShow edate
    calendarBodyView =
      if edate.datePickerOpen then
        Just (DateSelector.view min max selected |> VirtualDom.map dateSelectedMsg)
      else
        Nothing
  in
    visibilityController
      calendarToggleMsg
      (launcher edate.datePickerOpen (enhancedDateString edate) calendarToggleMsg)
      calendarBodyView

  
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

defaultDate = Date.Extra.fromCalendarDate 2018 Jan 1

bound shiftFunction edate =
  let
    shiftByYears date =
      Date.Extra.add Date.Extra.Year (shiftFunction 0 5) date
  in
    case dateToShow edate of
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
