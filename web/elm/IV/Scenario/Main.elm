module IV.Scenario.Main exposing (..)

import IV.Scenario.Msg exposing (..)
import IV.Scenario.Model exposing (EditableModel, defaultDecisions, editableBackground)
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

    ChangedBagCapacity string ->
      updateWhen string isValidFloatString model model_bagCapacity ! []
    ChangedBagContents string ->
      updateWhen string isValidFloatString model model_bagContents ! []
    ChangedDropsPerMil string ->
      updateWhen string isValidFloatString model model_dropsPerMil ! []
        
    OpenCaseBackgroundEditor ->
      ( model
          |> model_caseBackgroundEditorOpen.set True
          |> model_background.set editableBackground
          |> model_decisions.set defaultDecisions
      , Cmd.none
      )
    CloseCaseBackgroundEditor ->
      ( model_caseBackgroundEditorOpen.set False model
      , Cmd Out.PickedScenario
      )
    
updateWhen candidate pred model lens = 
  if pred candidate then
    lens.set candidate model
  else
    model
  
