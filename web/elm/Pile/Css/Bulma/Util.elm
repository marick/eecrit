module Pile.Css.Bulma.Util exposing (..)

import Pile.Css.H exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.HtmlShorthand exposing (..)


formStatusClasses : FormStatus -> Maybe String
formStatusClasses status = 
  if status == BeingSaved then
    Just "is-disabled"
  else
    Nothing

