module Pile.Css.Bulma.Button exposing (..)

import Pile.Css.H exposing (..)
import Pile.Css.Bulma.Util as Util

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.HtmlShorthand exposing (..)
import Maybe.Extra as Maybe

successButton buttonText disabledJudgment clickMsg =
  let
    attributes =
      [ Util.fullClass "button is-success" [disabledJudgment]
      , onClickPreventingDefault clickMsg
      ]
  in
    a attributes [ text buttonText ]
