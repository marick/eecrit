module IV.Scenario.Update exposing (..)

import String
import IV.Scenario.Msg exposing (..)
import IV.Scenario.Model exposing (Model, DripDesire)
import IV.Types exposing (..)

updateNextSpeed model nextString =
  if String.isEmpty nextString then
    {model | drip = DripDesire "" <| DropsPerSecond 0.0001 } -- bags leak
  else
    case String.toFloat nextString of
      Ok float ->
        {model | drip = DripDesire nextString <| DropsPerSecond float }
      Err _ ->
        model
              
  
update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangedTextField string ->
      updateNextSpeed model string
