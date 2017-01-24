module Pile.Css.Bulma.TextField exposing (..)

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

type alias Events msg =
  { typing : Maybe msg
  , enter : Maybe msg
  }
    
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
      
plainTextField : FormValue String -> EventControl msg -> Html msg
plainTextField formValue eventControl =
  let 
    rawFieldClass =
      Util.fullClass "input"
        [ maybeDisable eventControl
        , maybeShowDangerBorder formValue
        ]

    attributes =
      type_ "text"
        :: value formValue.value
        :: rawFieldClass
        :: eventAttributes eventControl
          
  in
    Util.control [] [input attributes []]

errorIndicatingTextField : FormValue String -> EventControl msg -> Html msg
errorIndicatingTextField formValue eventControl =
  let
    rawField =
      plainTextField formValue eventControl

    errorIndicators =
      (Maybe.maybeToList <| maybePutDangerIconInField formValue) ++
        validatedCommentary formValue
  in      
    Util.control
      [maybeAllowProblemIconInField formValue] 
      (rawField :: errorIndicators)


-- Helpers

validatedCommentary : FormValue t -> List (Html msg)
validatedCommentary formValue =
  let
    oneCommentary (urgency, string) =
      span [ class "help is-danger" ] [ text string ]
  in
    List.map oneCommentary formValue.commentary

maybeAllowProblemIconInField : FormValue t -> Maybe String
maybeAllowProblemIconInField formValue =
  case formValue.validity of
    Valid -> Nothing
    Invalid -> Just "has-icon has-icon-right"

maybePutDangerIconInField : FormValue t -> Maybe (Html msg)
maybePutDangerIconInField formValue =
  case formValue.validity of
    Valid -> Nothing
    Invalid -> Just <| i [class "fa fa-warning"] []

maybeShowDangerBorder : FormValue t -> Maybe String
maybeShowDangerBorder formValue =
  case formValue.validity of
    Valid -> Nothing
    Invalid -> Just "is-danger"

