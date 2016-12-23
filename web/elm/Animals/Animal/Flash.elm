module Animals.Animal.Flash exposing (..)

import Html exposing (..)
import Pile.Bulma as Bulma 


type AnimalFlash
  = NoFlash
  | SavedIncompleteTag String

showWithButton : AnimalFlash -> msg -> Html msg
showWithButton flash msg =
  case flash of 
    NoFlash -> 
      span [] []
    SavedIncompleteTag tagName -> 
      Bulma.flashNotification msg
        [ text "Excuse me for butting in, but I notice you clicked "
        , Bulma.exampleSuccess
        , text " while there was text in the "
        , b [] [text "New Tag"]
        , text " field. So I've added the tag "
        , Bulma.readOnlyTag tagName
        , text " for you."
        , text " You can delete it if I goofed."
        ]

