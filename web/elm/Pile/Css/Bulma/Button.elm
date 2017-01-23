module Pile.Css.Bulma.Button exposing (..)

import Pile.Css.H exposing (..)
import Pile.Css.Bulma.Util as Util

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.HtmlShorthand exposing (..)
import Maybe.Extra as Maybe

type EventControl msg
  = Inactive
  | Active msg

maybeDisable eventControl =
  if eventControl == Inactive then
    Just "is-disabled"
  else
    Nothing

eventAttributes : EventControl msg -> List (Attribute msg)
eventAttributes eventControl =
  case eventControl of
    Inactive ->
      []
    Active msg ->
      [onClickPreventingDefault msg]

successButton : String -> EventControl msg -> Html msg    
successButton buttonText eventControl  =
  let
    attributes =
      (Util.fullClass "button is-success" [maybeDisable eventControl])
        :: eventAttributes eventControl
  in
    a attributes [ text buttonText ]
