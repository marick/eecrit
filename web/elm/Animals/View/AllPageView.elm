module Animals.View.AllPageView exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import List
import Maybe.Extra as Maybe exposing ((?))
import String
import String.Extra as String

import Pile.Bulma as Bulma 
import Pile.Calendar as Calendar
import Pile.HtmlShorthand exposing (..)


view model =
  Bulma.infoMessage "Can't Add Animals Yet" "The page hasn't been written yet."
