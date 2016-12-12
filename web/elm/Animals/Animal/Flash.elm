module Animals.Animal.Flash exposing (..)

import Html exposing (..)
import Pile.Bulma as Bulma 


type Flash
  = NoFlash
  | SavedIncompleteTag String

showAndCancel : Flash -> (Flash -> msg) -> Html msg
showAndCancel flash partialMsg =
  case flash of 
    NoFlash -> 
      span [] []
    SavedIncompleteTag tagName -> 
      Bulma.flashNotification (partialMsg NoFlash)
        [ text "Excuse my presumption, but I notice you clicked "
        , Bulma.exampleSuccess
        , text " while there was text in the "
        , b [] [text "New Tag"]
        , text " field. So I've added the tag "
        , Bulma.readOnlyTag tagName
        , text " for you."
        , text " You can delete it if I goofed."
        ]

