module IV.Simulation.Main exposing (..)

import IV.Simulation.Msg exposing (..)
import IV.Types exposing (..)

type alias Model =
  { foo : String }

unstarted = { foo = "bar" }

update : Msg -> Model -> Model
update msg model =
  case msg of
    _ ->
      model
