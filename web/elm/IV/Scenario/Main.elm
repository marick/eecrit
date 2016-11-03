module IV.Scenario.Main exposing
  ( update
  , openCaseBackgroundEditor
  , closeCaseBackgroundEditor
  )

import IV.Scenario.Msg exposing (..)
import IV.Scenario.Model as Model exposing (EditableModel)
import IV.Scenario.Lenses exposing (..)
import IV.Pile.ManagedStrings exposing (..)

openCaseBackgroundEditor model = 
  ( model
    |> model_caseBackgroundEditorOpen.set True
    |> model_background.set Model.editableBackground
    |> model_decisions.set Model.defaultDecisions
  , Cmd.none
  )

closeCaseBackgroundEditor model =
  ( model 
    |> model_caseBackgroundEditorOpen.set False
  , Cmd.none
  )



update : Msg -> EditableModel -> (EditableModel, Cmd msg )
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
        
updateWhen candidate pred model lens = 
  if pred candidate then
    lens.set candidate model
  else
    model
  
