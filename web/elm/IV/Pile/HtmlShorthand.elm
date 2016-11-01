module IV.Pile.HtmlShorthand exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

row attrs elements =
  div ([class "row"] ++ attrs) elements

role = attribute "role"

