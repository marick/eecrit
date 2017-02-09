module Animals.Pages.HistoryPage exposing (..)

import Html exposing (..)
import Pile.Css.Bulma as Css
import Animals.Types.Basic exposing (..)

view : Id -> model -> Html msg
view id model =
  Css.infoMessage "Unfinished" "The help page hasn't been written yet."
