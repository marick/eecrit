module Animals.Pages.HelpPage exposing (..)

import Html exposing (..)
import Pile.Css.Bulma as Css

view : model -> Html msg
view model =
  Css.infoMessage [text "Unfinished"]
    [ text "The help page hasn't been written yet."]
