module Animals.View.AnimalFlash exposing (..)

import Animals.Msg exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.View.TextField as TextField

import Pile.Css.H as Css
import Pile.Css.Bulma as Css
import Pile.Css.Bulma.TextField as TextField
import Pile.Css.Bulma.Button as Button

import Html exposing (..)

type AnimalFlash
  = NoFlash
  | SavedIncompleteTag String
  | CopyInfoNeeded Id (Css.FormValue String) Int

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
    CopyInfoNeeded id countString countValue ->
      let
        onInput = WithDisplayedId id << UpdateCopyCount
        onSubmit = WithDisplayedId id <| AddFormsBasedOnAnimal countValue
        form = 
          countString
            |> TextField.events onInput (TextField.ClickAndEnterSubmits onSubmit)
            |> TextField.kind TextField.plainTextField
            |> TextField.buttonKind (Button.successButton "Create")
            |> TextField.build
             
      in
        Css.flashNotification flashRemovalMsg
          [ text "How many copies do you want?"
          , form
          ]

