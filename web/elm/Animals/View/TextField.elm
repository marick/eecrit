module Animals.View.TextField exposing (..)

import Animals.Types.Form exposing (Form)

import Pile.Css.H as Css
import Pile.Css.Bulma.Util as Css
import Pile.Css.Bulma.TextField as TextField
import Pile.Css.Bulma.Button as Button

import Html exposing (..)

type SubmitControl submitMsg
  = NeverSubmit
  | EnterSubmits submitMsg
  | ClickSubmits submitMsg
  | ClickAndEnterSubmits submitMsg

type OtherControls
  = VerticalForm
  | HorizontalForm

type alias Events msg =
  { typing : Maybe (String -> msg)
  , enter : Maybe msg
  , submit : Maybe msg
  }

noEvents =   
  { typing = Nothing
  , enter = Nothing
  , submit = Nothing
  }

type alias Builder msg =
  { events : Events msg
  , formValue : Css.FormValue String
  , field : Maybe (Html msg)
  , button : Maybe (Html msg)
  , layout : OtherControls
  }

 
calculateEvents : (String -> msg) -> SubmitControl msg -> Css.FormValue String
                  -> Events msg
calculateEvents editMsg submitControl formValue = 
  case formValue.validity of
    Css.Invalid ->
      { noEvents
        | typing = Just editMsg
      }
    Css.Valid ->
      case submitControl of
        NeverSubmit ->
          { noEvents
            | typing = Just editMsg
          }
        EnterSubmits submitMsg ->
          { noEvents
            | typing = Just editMsg
            ,  enter = Just submitMsg
          }
        ClickSubmits submitMsg ->
          { noEvents
            | typing = Just editMsg
            , submit = Just submitMsg
          }
        ClickAndEnterSubmits submitMsg ->
          { noEvents
            | typing = Just editMsg
            , enter = Just submitMsg
            , submit = Just submitMsg
          }
    
editingEvents : (String -> msg) -> SubmitControl msg -> Css.FormValue String
              -> Builder msg
editingEvents editMsg submitControl formValue =
  { events = calculateEvents editMsg submitControl formValue
  , formValue = formValue
  , field = Nothing
  , button = Nothing
  , layout = VerticalForm
  }
  
eventsObeyForm : Form -> Builder msg -> Builder msg
eventsObeyForm form builder =
  let
    events = 
      if (form.status == Css.BeingSaved) then
        { typing = Nothing,   enter = Nothing,  submit = Nothing }
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
      button = Just (buttonMaker {click = builder.events.submit })
  }

allowOtherControlsOnLine : Builder msg -> Builder msg
allowOtherControlsOnLine builder =
  { builder | layout = HorizontalForm }
  
build : Builder msg -> Html msg  
build builder =
  case (builder.field, builder.button, builder.layout) of
    (Just field, Nothing, VerticalForm) ->
      Css.aShortControlOnItsOwnLine field
    (Just field, Nothing, HorizontalForm) ->
      field
    (Just field, Just button, _) ->
      Css.controlWithAddons field [button]
    _ ->
      span []
        -- Todo: General handing/logging of "impossible" errors.
        [ text "You've discovered a bug. Sorry!" ] 
