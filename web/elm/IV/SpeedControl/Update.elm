module IV.SpeedControl.Update exposing (..)

import String
import IV.SpeedControl.Msg exposing (..)
import IV.SpeedControl.Model exposing (Model)
import IV.Types exposing (..)

updateNextSpeed model nextString =
  if String.isEmpty nextString then
    {model | string = nextString, perSecond = DropsPerSecond 0.1} -- bags leak
  else
    case String.toFloat nextString of
        Ok float ->
          {model
            | string = nextString
            , perSecond = (DropsPerSecond float)
          }
        Err _ ->
          model

  
update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangedTextField string ->
      updateNextSpeed model string
