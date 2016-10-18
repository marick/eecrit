module IV.Apparatus.Main exposing (..)

import IV.Apparatus.Msg exposing (..)
import IV.Types exposing (..)

type alias Model =
  { foo : String }

unstarted = { foo = "bar" }

update : Msg -> Model -> Model
update msg model =
  case msg of
    _ ->
      model
