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


type alias DateHolder record =
  { record
    | effectiveDate : EffectiveDate
    , today : Maybe Date
    , datePickerOpen : Bool
  }

type alias Launcher msg =
  Bool -> String -> msg -> Html msg

view : Launcher msg -> msg -> (Date -> msg) -> DateHolder record -> Html msg

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

  
enhancedDateString : DateHolder record -> String
enhancedDateString holder =
  let
    todayIfKnown =
      case holder.today of
        Nothing ->
          ""
        Just date ->
          Date.Extra.toFormattedString " (MMM d)" date
  in
    case holder.effectiveDate of
      Today -> 
        "Today" ++ todayIfKnown
      At date ->
        Date.Extra.toFormattedString "MMM d, y" date

          
dateToShow : DateHolder record -> Maybe Date
dateToShow holder =
  case holder.effectiveDate of 
    Today -> holder.today
    At date -> Just date

defaultDate : Date
defaultDate = Date.Extra.fromCalendarDate 2018 Jan 1

bound : (number -> number -> Int) -> DateHolder record -> Date
bound shiftFunction holder =
  let
    shiftByYears date =
      Date.Extra.add Date.Extra.Year (shiftFunction 0 5) date
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
