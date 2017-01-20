module Animals.View.AnimalFlash exposing (..)

import Animals.Msg exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal exposing (Animal)
import Pile.Css.Bulma as Css
import Html exposing (..)

type AnimalFlash
  = NoFlash
  | SavedIncompleteTag String
  | CopyInfoNeeded Id String

showWithButton : AnimalFlash -> Msg -> Html Msg
showWithButton flash flashRemovalMsg =
  case flash of 
    NoFlash -> 
      span [] []
    SavedIncompleteTag tagName -> 
      Css.flashNotification flashRemovalMsg
        [ text "Excuse me for butting in, but I notice you clicked "
        , Css.exampleSuccess
        , text " while there was text in the "
        , b [] [text "New Tag"]
        , text " field. So I've added the tag "
        , Css.readOnlyTag tagName
        , text " for you."
        , text " You can delete it if I goofed."
        ]
    CopyInfoNeeded id currentCount ->
      Css.flashNotification flashRemovalMsg
        [ text "How many copies do you want?"
        , Css.simpleTextInput
            currentCount
            (WithDisplayedId id << UpdateCopyCount)
        ]

