module Pile.Css.Bulma.TextField exposing (..)

import Pile.Css.H exposing (..)
import Pile.Css.Bulma.Util as Util
import Pile.HtmlShorthand exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Maybe.Extra as Maybe

type alias Events msg =
  { typing : Maybe (String -> msg)
  , enter : Maybe msg
  }
    
eventAttributes : Events msg -> List (Attribute msg)      
eventAttributes events =
  Maybe.values [ Maybe.map Events.onInput events.typing
               , Maybe.map onEnter events.enter
               ]

maybeDisable : Events msg -> Maybe String
maybeDisable events =
  case List.isEmpty (eventAttributes events) of
    True -> Just "is-disabled"
    False -> Nothing

-- Note that this does show a danger boarder if the value is invalid.
-- That's probably a good idea - a not IN YOUR FACE hint.
plainTextField : FormValue String -> Events msg -> Html msg
plainTextField formValue events =
  let 
    rawFieldClass =
      Util.fullClass "input"
        [ maybeDisable events
        , maybeShowDangerBorder formValue
        ]

    attributes =
      type_ "text"
        :: value formValue.value
        :: rawFieldClass
        :: eventAttributes events
          
  in
    Util.control [] [input attributes []]

errorIndicatingTextField : FormValue String -> Events msg -> Html msg
errorIndicatingTextField formValue events =
  let
    rawField =
      plainTextField formValue events

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

