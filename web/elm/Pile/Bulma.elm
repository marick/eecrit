module Pile.Bulma exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

tab selectedPage (page, linkText, msg) =
  let
    (liClass, linkStyle, spanClass) =
      if selectedPage == page then
        ( "is-active"
        , [ ("background-color", "#4a4a4a")
          , ("border-width", "1")
          , ("border-color", "#4a4a4a")
          , ("border-radius", "0px")
          ]
        , "is-info"
        )
      else
        ( "", [], "")
  in
    li [ class liClass ]
    [a [style linkStyle]
       [ span [class spanClass] [text linkText] ]
    ]
    
                   
tabs selectedPage tabList =
  div [class "tabs is-centered is-toggle"]
    [ ul [] <| List.map (tab selectedPage) tabList
    ]
