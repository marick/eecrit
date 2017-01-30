module Pile.DateHolder exposing
  ( DisplayDate(..)
  , DateHolder
  , enhancedDateString
  , convertToDate
    
  , startingState
  , choose
    
  , dateHolder_chosen
  , dateHolder_todayForReference
  , dateHolder_datePickerOpen
  )

import Date exposing (Date)
import Date.Extra as Date
import Pile.UpdatingLens exposing (UpdatingLens, lens)
import Pile.UpdatingOptional exposing (UpdatingOptional, opt)


type DisplayDate 
  = Today
  | At Date

type alias DateHolder =
  { chosen : DisplayDate
  , todayForReference : Maybe Date
  , datePickerOpen : Bool
  }

startingState : DateHolder
startingState = 
  { chosen = Today
  , todayForReference = Nothing -- It needs to be fetched from outside world
  , datePickerOpen = False
  }

-- If the chosen date is today, so note.
choose : Date -> DateHolder -> DateHolder
choose date holder =
  let 
    displayDate =
      case Maybe.map (Date.equalBy Date.Day date) holder.todayForReference of
        Just True -> Today
        _ -> At date
  in 
     dateHolder_chosen.set displayDate holder
  
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

convertToDate : DateHolder -> Date
convertToDate holder =
  case (holder.chosen, holder.todayForReference) of
    (Today, Just date) -> date
    (Today, Nothing) -> Date.fromCalendarDate 2000 Date.Jan 1 -- impossible
    (At date, _) -> date
  

-- Lenses

dateHolder_chosen : UpdatingLens DateHolder DisplayDate
dateHolder_chosen = lens .chosen (\ p w -> { w | chosen = p })

dateHolder_todayForReference : UpdatingOptional DateHolder Date
dateHolder_todayForReference =
  opt .todayForReference (\ p w -> { w | todayForReference = Just p })

dateHolder_datePickerOpen : UpdatingLens DateHolder Bool
dateHolder_datePickerOpen = lens .datePickerOpen (\ p w -> { w | datePickerOpen = p })

