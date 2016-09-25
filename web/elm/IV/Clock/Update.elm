module IV.Clock.Update exposing (..)

import Animation
import IV.Clock.Msg exposing (Msg(..))
import IV.Clock.Model as Model exposing (Model)
import IV.Clock.View as View
import Time exposing (second)
import IV.Types exposing (..)

update : Msg -> Model -> Model
update msg model =
  case msg of
    AdvanceHours hours ->
      model
