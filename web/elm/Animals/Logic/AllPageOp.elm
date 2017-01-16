module Animals.Logic.AllPageOp exposing
  ( update
  )

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)

import Pile.UpdateHelpers exposing (..)
import Pile.Calendar as Calendar

update : AllPageOperation -> Model -> (Model, Cmd Msg)
update op model = 
  case op of
    ToggleDatePicker ->
      model |> model_datePickerOpen.update not |> noCmd
    SelectDate date ->
      model |> model_effectiveDate.set (Calendar.At date) |> noCmd
      
    SetNameFilter s ->
      model |> model_nameFilter.set s |> noCmd
    SetTagFilter s ->
      model |> model_tagFilter.set s |> noCmd
    SetSpeciesFilter s ->
      model |> model_speciesFilter.set s |> noCmd

