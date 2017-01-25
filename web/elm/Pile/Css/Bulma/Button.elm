module Pile.Css.Bulma.Button exposing (..)

import Pile.Css.H exposing (..)
import Pile.Css.Bulma.Util as Util

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.HtmlShorthand exposing (..)
import Maybe.Extra as Maybe

type alias Events msg =
  { click : Maybe msg
  }

eventsFromValue formValue submitMsg =
  case formValue.validity of
    Valid -> {click = Just submitMsg}
    Invalid -> {click = Nothing}

maybeDisable events =
  case events.click of
    Nothing -> Just "is-disabled"
    Just _ -> Nothing

eventAttributes : Events msg -> List (Attribute msg)
eventAttributes events =
  case events.click of
    Nothing ->
      []
    Just msg ->
      [onClickPreventingDefault msg]

rawButton : String -> String -> Events msg -> Html msg
rawButton baseClass buttonText events = 
  let
    attributes =
      (Util.fullClass baseClass [maybeDisable events])
        :: eventAttributes events
  in
    a attributes [ text buttonText ]
            
        
successButton : String -> Events msg -> Html msg    
successButton = rawButton "button is-success" 

primaryButton : String -> Events msg -> Html msg    
primaryButton = rawButton "button is-primary" 

      
