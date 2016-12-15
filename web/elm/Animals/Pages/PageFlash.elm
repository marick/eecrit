module Animals.Pages.PageFlash exposing (..)

import Html exposing (..)
import Pile.Bulma as Bulma 
import Animals.Msg exposing (Msg(..))

type Flash
  = NoFlash
  | SavedAnimalFlash

show : Flash -> Html Msg
show flash =
  case flash of 
    NoFlash -> 
      span [] []
    SavedAnimalFlash -> 
      Bulma.flashNotification NoOp
        [ text "The new animal can be seen on the All Animals page." ]

