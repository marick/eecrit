module Animals.View.AnimalFlash exposing (..)

import Animals.Msg exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal exposing (Animal)
import Pile.Css.H as Css
import Pile.Css.Bulma as Css
import Pile.ConstrainedStrings as Constrained
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
        -- Note: this does allow user create to 0 animals
        value = Constrained.convertWithDefaultInt 0 currentCount
        status = case value == 0 of  -- TODO: Must be a function that does this.
                   True -> Css.SomeBad
                   False -> Css.AllGood

      in
        Css.flashNotification flashRemovalMsg
          [ text "How many copies do you want?"
          , Css.textInputWithSubmit
              status
              "Create"
              currentCount
              (WithDisplayedId id << UpdateCopyCount)
              (WithDisplayedId id <| AddFormsBasedOnAnimal value)
          ]

