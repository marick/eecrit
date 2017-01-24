module Animals.View.TextField exposing (..)

import Html exposing (..)
import Html.Events as Events

import Pile.Css.H as Css
import Pile.Css.Bulma as Css
import Pile.Css.Bulma.Util as Css
import Pile.Css.Bulma.TextField as TextField
import Pile.Css.Bulma.Button as Button
import Pile.HtmlShorthand exposing (..)

import Animals.Msg exposing (..)
import Animals.Types.Form exposing (Form)

type SubmitControl submitMsg
  = NeverSubmit
  | EnterSubmits submitMsg
  | ClickSubmits submitMsg
  | ClickAndEnterSubmits submitMsg

type WhatFollows
  = EndsLine

type alias Events msg =
  { typing : Maybe (String -> msg)
  , enter : Maybe msg
  , click : Maybe msg
  }

type alias Builder msg =
  { events : Events msg
  , formValue : Css.FormValue String
  , field : Maybe (Html msg)
  , button : Maybe (Html msg)
  }

 
calculateEvents : (String -> msg) -> SubmitControl msg -> Css.FormValue String
                  -> Events msg
calculateEvents editMsg submitControl formValue = 
  case formValue.validity of
    Css.Invalid ->
      { typing = Just editMsg, enter = Nothing, click = Nothing }
    Css.Valid ->
      case submitControl of
        NeverSubmit ->
          { typing = Just editMsg,   enter = Nothing,        click = Nothing }
        EnterSubmits submitMsg ->
          { typing = Just editMsg,   enter = Just submitMsg, click = Nothing }
        ClickSubmits submitMsg ->
          { typing = Just editMsg,   enter = Nothing,        click = Just submitMsg }
        ClickAndEnterSubmits submitMsg ->
          { typing = Just editMsg,   enter = Just submitMsg, click = Just submitMsg }
    
events : (String -> msg) -> SubmitControl msg -> Css.FormValue String -> Builder msg
events editMsg submitControl formValue =
  { events = calculateEvents editMsg submitControl formValue
  , formValue = formValue
  , field = Nothing
  , button = Nothing
  }

  
eventsObeyForm : Form -> Builder msg -> Builder msg
eventsObeyForm form builder =
  let
    events = 
      if (form.status == Css.BeingSaved) then
        { typing = Nothing,   enter = Nothing,  click = Nothing }
      else
        builder.events
  in
    { builder | events = events }

kind : (Css.FormValue String -> TextField.Events msg -> Html msg) -> Builder msg
     -> Builder msg
kind fieldMaker builder =
  let
    relevantEvents = { typing = builder.events.typing
                       , enter = builder.events.enter
                       }
  in
    { builder
      | field = Just (fieldMaker builder.formValue relevantEvents) }

buttonKind : (Button.Events msg -> Html msg) -> Builder msg -> Builder msg
buttonKind buttonMaker builder =
  { builder |
      button = Just (buttonMaker {click = builder.events.click })
  }

  
build : Builder msg -> Html msg  
build builder =
  case (builder.field, builder.button) of
    (Just field, Nothing) ->
      Css.aShortControlOnItsOwnLine field
    (Just field, Just button) ->
      Css.controlWithAddons field [button]
    _ ->
      span []
        -- Todo: General handing/logging of "impossible" errors.
        [ text "You've discovered a bug. Sorry!" ] 
