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
        
defaultDate : Date.Date
defaultDate = Date.fromCalendarDate 2018 Date.Jan 1

