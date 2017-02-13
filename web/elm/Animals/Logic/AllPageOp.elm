module Animals.Logic.AllPageOp exposing
  ( update
  )

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)
import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Conversions as Convert 
import Animals.Types.DisplayedCollections as Displayable
import Animals.OutsideWorld.Cmd as OutsideWorld

import Pile.UpdateHelpers exposing (..)
import Pile.DateHolder as DateHolder
import Set exposing (Set)

update : AllPageOperation -> Model -> (Model, Cmd Msg)
update op model = 
  case op of
    OpenDatePicker ->
      let
        startingPickerDate =
          DateHolder.convertToDate model.effectiveDate
      in 
        model
          |> model_datePickerState.set (DateHolder.ModalPickerOpen startingPickerDate)
          |> noCmd

    CalendarClick date ->
      model
        |> model_datePickerState.set (DateHolder.ModalPickerOpen date)
        |> noCmd
           
    SaveCalendarDate ->
      let 
        newEffectiveDate =
          DateHolder.destructivelyChooseCalendarDate model.effectiveDate
        rawDate =
          DateHolder.convertToDate newEffectiveDate
      in 
        model
          |> model_effectiveDate.set newEffectiveDate
          -- erase page now to give faster feedback.
          |> erasePage
          |> addCmd (OutsideWorld.fetchAnimals rawDate)
             
    DiscardCalendarDate ->
      model |> model_datePickerState.set DateHolder.PickerClosed |> noCmd
      
    SetAnimals animals ->
      model
        |> erasePage -- it doesn't hurt to be sure
        |> addToPage animals
        |> noCmd

    SetNameFilter s ->
      model |> model_nameFilter.set s |> noCmd
    SetTagFilter s ->
      model |> model_tagFilter.set s |> noCmd
    SetSpeciesFilter s ->
      model |> model_speciesFilter.set s |> noCmd


        
addToPage : List Animal -> Model -> Model 
addToPage animals model =
  let
    newDisplayables = List.map Convert.animalToDisplayed animals
    newIds = Displayable.idSet newDisplayables
  in
    model
      |> model_displayables.update (Displayable.add newDisplayables)
      |> model_allPageAnimals.update (Set.union newIds)

erasePage : Model -> Model 
erasePage model =
  model
    |> model_displayables.update (Displayable.removeMembers model.allPageAnimals)
    |> model_allPageAnimals.set Set.empty
