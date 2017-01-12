module Animals.Animal.Flash exposing (..)

import Html exposing (..)
import Pile.Css.Bulma as Css


type AnimalFlash
  = NoFlash
  | SavedIncompleteTag String

showWithButton : AnimalFlash -> msg -> Html msg
showWithButton flash msg =
  case flash of 
    NoFlash -> 
      span [] []
    SavedIncompleteTag tagName -> 
      Css.flashNotification msg
        [ text "Excuse me for butting in, but I notice you clicked "
        , Css.exampleSuccess
        , text " while there was text in the "
        , b [] [text "New Tag"]
        , text " field. So I've added the tag "
        , Css.readOnlyTag tagName
        , text " for you."
        , text " You can delete it if I goofed."
        ]

