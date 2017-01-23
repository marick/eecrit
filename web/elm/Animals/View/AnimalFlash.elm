module Animals.View.AnimalFlash exposing (..)

import Animals.Msg exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal exposing (Animal)
import Pile.Css.H as Css
import Pile.Css.Bulma as Css
import Pile.Css.Bulma.Util as Css
import Pile.ConstrainedStrings as Constrained
import Pile.Css.Bulma.TextField as TextField
import Pile.Css.Bulma.Button as Button
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
      let
        value = Constrained.convertWithDefaultInt 0 currentCount
        onInput = WithDisplayedId id << UpdateCopyCount
        onSubmit = WithDisplayedId id <| AddFormsBasedOnAnimal value
                            
        textEventControl =
          if value == 0 then
            TextField.EditOnly onInput
          else
            TextField.BothEditAndSubmit onInput onSubmit

        buttonEventControl =
          if value == 0 then
            Button.Inactive
          else
            Button.Active onSubmit

        input = 
          TextField.errorIndicatingTextField
            (Css.freshValue currentCount)
            textEventControl

        button =
          Button.successButton
            "Create"
            buttonEventControl 
      in
        Css.flashNotification flashRemovalMsg
          [ text "How many copies do you want?"
          , Css.controlWithAddons input [button]
          ]

