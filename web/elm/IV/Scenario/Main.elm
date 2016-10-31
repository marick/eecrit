module IV.Scenario.Main exposing (..)

import IV.Scenario.Msg exposing (..)
import IV.Scenario.Model exposing (EditableModel)
import IV.Scenario.Lenses exposing (..)
import IV.Pile.ManagedStrings exposing (..)
import IV.Msg as Out


update : Msg -> EditableModel -> (EditableModel, Cmd Out.Msg )
update msg model =
  case msg of
    ChangedDripText string ->
      updateWhen string isValidFloatString model model_dripRate ! []
    ChangedHoursText string ->
      updateWhen string isValidIntString model model_simulationHours ! []
    ChangedMinutesText string ->
      updateWhen string isValidIntString model model_simulationMinutes ! []
    OpenCaseBackgroundEditor ->
      { model | caseBackgroundEditorOpen = True } ! []
    CloseCaseBackgroundEditor ->
      { model | caseBackgroundEditorOpen = False } ! []
                
    
updateWhen candidate pred model lens = 
  if pred candidate then
    lens.set candidate model
  else
    model
  
