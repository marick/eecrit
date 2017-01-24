module Pile.Css.Bulma.Button exposing (..)

import Pile.Css.H exposing (..)
import Pile.Css.Bulma.Util as Util

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.HtmlShorthand exposing (..)
import Maybe.Extra as Maybe

type alias Events msg =
  { click : Maybe msg
  }

maybeDisable events =
  case events.click of
    Nothing -> Just "is-disabled"
    Just _ -> Nothing

eventAttributes : Events msg -> List (Attribute msg)
eventAttributes events =
  case events.click of
    Nothing ->
      []
    Just msg ->
      [onClickPreventingDefault msg]

successButton : String -> Events msg -> Html msg    
successButton buttonText events  =
  let
    attributes =
      (Util.fullClass "button is-success" [maybeDisable events])
        :: eventAttributes events
  in
    a attributes [ text buttonText ]
