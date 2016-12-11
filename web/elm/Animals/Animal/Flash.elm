module Animals.Animal.Flash exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.HtmlShorthand exposing (..)
import Pile.Bulma as Bulma 

import Dict
import List
import String
import String.Extra as String

import Animals.Animal.Model exposing (..)
import Animals.Msg exposing (..)
import Animals.Animal.Edit exposing (..)

showAndCancel : Flash -> (Flash -> Msg) -> Html Msg
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

