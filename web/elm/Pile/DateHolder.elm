module Pile.DateHolder exposing
  ( DisplayDate(..)
  , DateHolder
  , DatePickerState(..)
  , enhancedDateString
  , convertToDate
  , todayDate
    
  , startingState
  , choose
  , destructivelyChooseCalendarDate
  , chooseToday
  , datePickerOpen

  , compare
  , firstAfterSecond
  , dateHolder_chosen
  , dateHolder_todayForReference
  , dateHolder_pickerState
  )

import Date exposing (Date)
import Date.Extra as Date
import Pile.Date as Date
import Pile.UpdatingLens exposing (UpdatingLens, lens)
import Pile.UpdatingOptional exposing (UpdatingOptional, opt)


type DisplayDate 
  = Today
  | At Date

type DatePickerState
  -- The holder stashes the date until it replaces the chosen date.
  = ModalPickerOpen Date
  -- Changes to the selected date must update the effective date immediately.
  | PickerOpen
  | PickerClosed


type alias DateHolder =
  { chosen : DisplayDate
  , todayForReference : Maybe Date
  , pickerState : DatePickerState
  }

datePickerOpen holder =
  holder.pickerState /= PickerClosed

startingState : DateHolder
startingState = 
  { chosen = Today
  , todayForReference = Nothing -- It needs to be fetched from outside world
  , pickerState = PickerClosed
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


destructivelyChooseCalendarDate : DateHolder -> DateHolder
destructivelyChooseCalendarDate holder =
  let
    close = dateHolder_pickerState.set PickerClosed
  in
    case holder.pickerState of
      PickerClosed ->
        close holder
      PickerOpen ->
        close holder
      ModalPickerOpen date ->
        holder |> choose date |> close
        
  
enhancedDateString : DateHolder -> String
enhancedDateString holder =
  let
    todayIfKnown =
      case holder.todayForReference of
        Nothing ->
          ""
        Just date ->
          " (" ++ Date.terse date ++ ")"
  in
    case holder.chosen of
      Today -> 
        "Today" ++ todayIfKnown
      At date ->
        Date.humane date

convertToDate : DateHolder -> Date
convertToDate holder =
  case (holder.chosen, holder.todayForReference) of
    (Today, Just date) -> date
    (Today, Nothing) -> Date.fromCalendarDate 2000 Date.Jan 1 -- impossible
    (At date, _) -> date

todayDate: DateHolder -> Date
todayDate holder = 
  case holder.todayForReference of
    Just date -> date
    Nothing -> Date.fromCalendarDate 2000 Date.Jan 1 -- impossible

chooseToday: DateHolder -> DateHolder
chooseToday holder =
  { holder | chosen = Today}

compare: DateHolder -> DateHolder -> Order
compare one another =
  let
    actualOne = convertToDate one
    actualOther = convertToDate another
  in
    Date.compare actualOne actualOther
         
    
firstAfterSecond: DateHolder -> DateHolder -> Bool
firstAfterSecond first second =
  (compare first second) == GT

-- Lenses

dateHolder_chosen : UpdatingLens DateHolder DisplayDate
dateHolder_chosen = lens .chosen (\ p w -> { w | chosen = p })

dateHolder_todayForReference : UpdatingOptional DateHolder Date
dateHolder_todayForReference =
  opt .todayForReference (\ p w -> { w | todayForReference = Just p })

dateHolder_pickerState : UpdatingLens DateHolder DatePickerState
dateHolder_pickerState = lens .pickerState (\ p w -> { w | pickerState = p })

