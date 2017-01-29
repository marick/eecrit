module Pile.Calendar exposing ( view )

import Pile.DateHolder as DateHolder exposing (DateHolder, DisplayDate(..))

import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Date
import Date.Extra as Date
import DateSelector

type alias CalendarParams =
  { min : Date.Date
  , max : Date.Date
  , selected : Maybe Date.Date
  }

view : DateHolder -> (Date.Date -> msg) -> Html msg
view holder pickMsg =
  let
    params = calendarParams holder
  in
    DateSelector.view params.min params.max params.selected
      |> Html.map pickMsg


-- Util
         
calendarParams holder =
  { min = (bound (-) holder)
  , max = (bound (+) holder)
  , selected = dateToShow holder
  }

bound : (number -> number -> Int) -> DateHolder -> Date.Date
bound shiftFunction holder =
  let
    shiftByYears date =
      Date.add Date.Year (shiftFunction 0 5) date
  in
    case dateToShow holder of
      Nothing -> shiftByYears defaultDate
      Just date -> shiftByYears date

dateToShow : DateHolder -> Maybe Date.Date
dateToShow holder =
  case holder.chosen of 
    Today -> holder.todayForReference
    At date -> Just date





-- A view that I've discarded. Retained in case I ever want a popdown
-- menu again.
         
type alias Launcher msg =
  Bool -> String -> msg -> Html msg

oldView : Launcher msg -> msg -> (Date.Date -> msg) -> DateHolder -> Html msg
oldView launcher calendarToggleMsg dateSelectedMsg holder =
  let
    params =
      calendarParams holder
    calendarBodyView =
      if holder.datePickerOpen then
        DateSelector.view params.min params.max params.selected
          |> Html.map dateSelectedMsg
          |> Just
      else
        Nothing
  in
    visibilityController
      calendarToggleMsg
      (launcher holder.datePickerOpen
         (DateHolder.enhancedDateString holder)
         calendarToggleMsg)
      calendarBodyView

        
defaultDate : Date.Date
defaultDate = Date.fromCalendarDate 2018 Date.Jan 1

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
