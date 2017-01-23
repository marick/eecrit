module Pile.Css.Bulma.TextInput exposing (..)

import Pile.Css.H exposing (..)
import Pile.Css.Bulma.Util as Util

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.HtmlShorthand exposing (..)
import Maybe.Extra as Maybe

type EventControl msg
  = NeitherEditNorSubmit
  | EditOnly (String -> msg)
  | BothEditAndSubmit (String -> msg) msg 

maybeDisable eventControl =
  if eventControl == NeitherEditNorSubmit then
    Just "is-disabled"
  else
    Nothing

eventAttributes : EventControl msg -> List (Attribute msg)      
eventAttributes eventControl =
  case eventControl of
    NeitherEditNorSubmit ->
      []
    EditOnly msg ->
      [Events.onInput msg]
    BothEditAndSubmit editMsg submitMsg ->
      [Events.onInput editMsg, onEnter submitMsg]
      
plainTextField : String -> List (Attribute msg) -> Html msg
plainTextField string extraAttributes =
  let 
    attributes = type_ "text" :: value string :: extraAttributes
  in
    input attributes []

errorIndicatingTextInput : FormValue String -> EventControl msg -> Html msg
errorIndicatingTextInput fieldValue eventControl =
  let
    rawFieldClass =
      Util.fullClass "input"
        [ maybeDisable eventControl
        , maybeShowDangerBorder fieldValue
        ]

    events =
      eventAttributes eventControl
        
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

