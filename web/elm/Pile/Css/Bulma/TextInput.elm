module Pile.Css.Bulma.TextInput exposing (..)

import Pile.Css.H exposing (..)
import Pile.Css.Bulma.Util as Util

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.HtmlShorthand exposing (..)
import Maybe.Extra as Maybe

plainTextField : String -> List (Attribute msg) -> Html msg
plainTextField string extraAttributes =
  let 
    attributes = type_ "text" :: value string :: extraAttributes
  in
    input attributes []

errorIndicatingTextInput : FormValue String -> Maybe String -> List (Attribute msg)
                         -> Html msg
errorIndicatingTextInput fieldValue disabledJudgment events =
  let
    rawFieldClass =
      Util.fullClass "input"
        [ disabledJudgment
        , maybeShowDangerBorder fieldValue
        ]

    rawField =
      plainTextField fieldValue.value (rawFieldClass :: events)

    errorIndicators =
      (Maybe.maybeToList <| maybePutDangerIconInField fieldValue) ++
        validatedCommentary fieldValue
  in      
    Util.control
      [maybeAllowProblemIconInField fieldValue] 
      (rawField :: errorIndicators)


-- Helpers

validatedCommentary : FormValue t -> List (Html msg)
validatedCommentary fieldValue =
  let
    oneCommentary (urgency, string) =
      span [ class "help is-danger" ] [ text string ]
  in
    List.map oneCommentary fieldValue.commentary

maybeAllowProblemIconInField : FormValue t -> Maybe String
maybeAllowProblemIconInField fieldValue =
  case fieldValue.validity of
    Valid -> Nothing
    Invalid -> Just "has-icon has-icon-right"

maybePutDangerIconInField : FormValue t -> Maybe (Html msg)
maybePutDangerIconInField fieldValue =
  case fieldValue.validity of
    Valid -> Nothing
    Invalid -> Just <| i [class "fa fa-warning"] []

maybeShowDangerBorder : FormValue t -> Maybe String
maybeShowDangerBorder fieldValue =
  case fieldValue.validity of
    Valid -> Nothing
    Invalid -> Just "is-danger"

