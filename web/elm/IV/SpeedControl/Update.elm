module IV.SpeedControl.Update exposing (..)

import String
import IV.SpeedControl.Msg exposing (..)
import IV.SpeedControl.Model exposing (Model)

updateNextSpeed model nextString =
  if String.isEmpty nextString then
    {model | string = nextString, float = 0.0}
  else
    case String.toInt nextString of
        Ok int ->
          {model | string = nextString, float = toFloat int}
        Err _ ->
          model

  
update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangedTextField string ->
      updateNextSpeed model string
