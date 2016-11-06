module C4u.View.MainPage exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import C4u.Main exposing (Model)
import C4u.Msg exposing (Msg(..))



view : Model -> Html Msg
view model =
  div []
    [
     text "So this is the beginning of the Critter4Us SPA"
    ]
