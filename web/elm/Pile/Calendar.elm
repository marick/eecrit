module Pile.Calendar exposing ( view )

import Html exposing (Html, div)
import Date exposing (Date)
import Date.Extra as Date
import DateSelector

type alias CalendarParams =
  { min : Date
  , max : Date
  , selected : Maybe Date
  }

view : Date -> (Date -> msg) -> Html msg
view chosenDate pickMsg =
  let
    params = calendarParams chosenDate
  in
    DateSelector.view params.min params.max (Just params.selected)
      |> Html.map pickMsg


-- Util
         
calendarParams : Date -> { max : Date, min : Date, selected : Date }
calendarParams chosenDate =
  { min = (bound (-) chosenDate)
  , max = (bound (+) chosenDate)
  , selected = chosenDate
  }

bound : (number -> number -> Int) -> Date -> Date
bound shiftFunction date =
  Date.add Date.Year (shiftFunction 0 5) date

