module IV.Scenario.Update exposing (..)

import String
import IV.Scenario.Msg exposing (..)
import IV.Scenario.Model exposing (Model)
import IV.Types exposing (..)
import IV.Pile.ManagedStrings exposing (..)




updateNextSpeed model nextString =
  if isValidFloatString nextString then
    {model | dripText = nextString }
  else
    model
              
  
update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangedDripText string ->
      updateNextSpeed model string
