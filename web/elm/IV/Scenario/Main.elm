module IV.Scenario.Main exposing (..)

import IV.Scenario.Msg exposing (..)
import IV.Scenario.Models exposing (..)
import IV.Types exposing (..)
import IV.Pile.ManagedStrings exposing (..)
import String
import IV.Msg as Out



-- Update

update : Msg -> EditableModel -> (EditableModel, Cmd Out.Msg )
update msg model =
  case msg of
    ChangedDripText string ->
      updateWhen string isValidFloatString model dripText' 
    ChangedHoursText string ->
      updateWhen string isValidIntString model simulationHoursText'
    ChangedMinutesText string ->
      updateWhen string isValidIntString model simulationMinutesText'
    OpenCaseBackgroundEditor ->
      { model | caseBackgroundEditorOpen = True } ! []
                
dripText' editableModel val =
  let
    decisions = editableModel.decisions
    newDecisions = { decisions | dripText = val }
  in
    { editableModel | decisions = newDecisions }
    
simulationHoursText' editableModel val =
  let
    decisions = editableModel.decisions
    newDecisions = { decisions | simulationHoursText = val }
  in
    { editableModel | decisions = newDecisions }

simulationMinutesText' editableModel val =
  let
    decisions = editableModel.decisions
    newDecisions = { decisions | simulationMinutesText = val }
  in
    { editableModel | decisions = newDecisions }
    
updateWhen : String -> (String -> Bool) -> EditableModel -> (EditableModel -> String -> EditableModel) -> (EditableModel, Cmd Out.Msg)
updateWhen candidate pred model updater =
  ( if pred candidate then
      updater model candidate
    else
      model
  , Cmd.none
  )
