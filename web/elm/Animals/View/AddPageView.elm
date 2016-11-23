module Animals.View.AddPageView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.Bulma as Bulma

view model =
  Bulma.infoMessage "Can't Add Animals Yet" "The page hasn't been written yet."
