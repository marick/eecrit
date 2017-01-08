module Animals.Pages.HelpPage exposing (..)

import Html exposing (..)
import Pile.Bulma as Bulma

view : model -> Html msg
view model =
  Bulma.infoMessage "Unfinished" "The help page hasn't been written yet."
