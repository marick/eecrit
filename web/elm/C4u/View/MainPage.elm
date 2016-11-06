module C4u.View.MainPage exposing (view)

import Html.Events as Events
import Html exposing (..)
import Html.Attributes exposing (..)
import List

import C4u.Main exposing (Model)
import C4u.Msg exposing (Msg(..))


entry line =
  li [] [text line ]

view : Model -> Html Msg
view model =
  div []
    [ text "So this is the beginning of the Critter4Us SPA"
    , button [Events.onClick (SetVal 55)] [text "set to 5"]
    , hr [] []
    , ul [] (List.map entry model.notes)
    ]
