module Pile.Bulma exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.HtmlShorthand exposing (..)
import Html.Events as Events

tab selectedPage (page, linkText, msg) =
  let
    (liClass, linkClass, linkStyle, spanClass) =
      if selectedPage == page then
        ( "is-active"
        , "is-disabled"
        , [ ("background-color", "#4a4a4a")
          , ("border-width", "1")
          , ("border-color", "#4a4a4a")
          , ("border-radius", "0px")
          ]
        , "is-info"
        )
      else
        ( "", "", [], "")
  in
    li [ class liClass ]
     [a [ class linkClass
        , style linkStyle
        , href "#" -- Note: without this, event won't be fired.
        , onClickWithoutPropagation msg
        ]
       [ span [class spanClass] [text linkText] ]
    ]
    
                   
tabs selectedPage tabList =
  div [class "tabs is-centered is-toggle"]
    [ ul [] <| List.map (tab selectedPage) tabList
    ]

shortenWidth content =
  div [class "columns is-centered is-mobile"]
    [ div [class "column is-10 has-text-centered"]
        content
    ] 

message kind header body =
  shortenWidth
    [ article [class <| "message " ++ kind ]
        [ div [ class "message-header" ] [ text header ] 
        , div [ class "message-body"] [ text body ]
        ]
    ]

infoMessage = message "is-info"



tdIcon iconSymbolName tooltip msg =
  td [class "is-icon"]
    [a [ href "#"
       , title tooltip
       , onClickWithoutPropagation msg
       ]
       [i [class ("fa " ++ iconSymbolName)] []]
    ]

plainIcon iconSymbolName tooltip msg =
  a [ href "#"
    , class "icon"
    , title tooltip
    , onClickWithoutPropagation msg
    ]
    [i [class ("fa " ++ iconSymbolName)] []]

    
rightIcon iconSymbolName tooltip msg =
  a [ href "#"
    , class "icon is-pulled-right"
    , title tooltip
    , onClickWithoutPropagation msg
    ]
    [i [class ("fa " ++ iconSymbolName)] []]

coloredIcon iconName color =
  i [class ("fa " ++ iconName)
    , style [("color", color)]
    ] []

trueIcon = coloredIcon "fa-check" "green"
falseIcon = coloredIcon "fa-times" "red"
              
readOnlyTag tagText =
  span [ class "tag" ] [ text tagText ]
    
deletableTag tagText =
  p [ class "tag is-primary control" ]
    [ text tagText
    , button [class "delete"] []
    ]
    
messageView headerList contentList  =
  article [class "message"]
    [ div [class "message-header has-text-centered"] headerList
    , div [class "message-body"] contentList
    ]

centeredLevelItem content =
  div [class "level-item has-text-centered"]
    content

simpleSelect content = 
  span [ class "select" ]
    [ select [] content ]

headingP heading = 
  p [class "heading"] [text heading]

simpleTextInput val msg = 
  p [class "control"]
    [input
       [ class "input"
       , type' "text"
       , value val
       , Events.onInput msg]
       []
    ]

centeredColumns contents =
  div [class "columns is-centered"] contents

column n contents =
  div [class ("column is-" ++ (toString n))] contents



headerlessTable body = 
  table [class "table"]
    [ tbody [] body ]

propertyTable body = 
  table [ style [("width", "auto")]
        , class "table is-bordered"
        ]
    [ tbody [] body ]

distributeHorizontally contents =
  div [class "level"] contents
