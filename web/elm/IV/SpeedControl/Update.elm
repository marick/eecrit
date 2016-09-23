module IV.SpeedControl.Update exposing (..)

import String
import IV.SpeedControl.Msg exposing (..)
import IV.SpeedControl.Model exposing (Model)

updateNextSpeed model nextString =
  if String.isEmpty nextString then
    {model | desiredNextSpeed = nextString}
  else
    case String.toInt nextString of
        Ok _ ->
          {model | desiredNextSpeed = nextString}
        Err _ ->
          model

update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangedTextField string ->
      updateNextSpeed model string
