module Pile.Css.Bulma.TextInput exposing (..)

import Pile.Css.H exposing (..)
import Pile.Css.Bulma.Util as Util

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.HtmlShorthand exposing (..)
import Maybe.Extra as Maybe

errorIndicatingTextInput fieldValue classAdjustments whenUserTypes =
  let
    isolatedInput =
      input
        [ fullClass "input"
            [ classAdjustments
            , maybeShowDangerBorder fieldValue
            ]
        , type_ "text"
        , value fieldValue.value
        , Events.onInput whenUserTypes
        ]
        []
  in      
    List.concat
      [ [isolatedInput]
      , Maybe.maybeToList <| maybePutDangerIconInField fieldValue
      , validatedCommentary fieldValue
      ]
      

aShortControlOnItsOwnLine : Html msg -> Html msg
aShortControlOnItsOwnLine control = 
  div [class "control is-grouped"]
    [ p [class "control"]
        [ control
        ]
    ]
    
soleTextInputInRow formStatus fieldValue msg =
  let
    attributes =
      [ fullClass "control" [maybeAllowProblemIconInField fieldValue]]
    content =
      errorIndicatingTextInput
        fieldValue
        (Util.formStatusClasses formStatus)
        msg
  in
    aShortControlOnItsOwnLine <| p attributes content

-- Helpers

validatedCommentary fieldValue =
  let
    oneCommentary (urgency, string) =
      span [ class "help is-danger" ] [ text string ]
  in
    List.map oneCommentary fieldValue.commentary

maybeAllowProblemIconInField fieldValue =
  case fieldValue.validity of
    Valid -> Nothing
    Invalid -> Just "has-icon has-icon-right"

maybePutDangerIconInField fieldValue =
  case fieldValue.validity of
    Valid -> Nothing
    Invalid -> Just <| i [class "fa fa-warning"] []

maybeShowDangerBorder fieldValue =
  case fieldValue.validity of
    Valid -> Nothing
    Invalid -> Just "is-danger"

fullClass base maybeExtras =
  class <| String.join " " (base :: Maybe.values maybeExtras)

