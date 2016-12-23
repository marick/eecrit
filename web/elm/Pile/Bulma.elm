module Pile.Bulma exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.HtmlShorthand exposing (..)
import Html.Events as Events

type Urgency
  = Info 
  | Error

type Validity
  = Valid
  | Invalid

type alias FormValue t =
  { validity : Validity
  , value : t
  , commentary : List (Urgency, String)
  }




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
    
deletableTag msg tagText =
  p [ class "tag is-primary control" ]
    [ text tagText
    , button
        [ class "delete"
        , Events.onClick (msg tagText)
        ] []
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

disabledSelect content = 
  span [ class "select" ]
    [ select [disabled True] content ]

headingP heading = 
  p [class "heading"] [text heading]

simpleTextInput val msg = 
  p [class "control"]
    [input
       [ class "input"
       , type_ "text"
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

highlightedRow attributes cells =
  let
    emphasis = style [ ("border-top", "2px solid")
                     , ("border-bottom", "2px solid")
                     ]
  in
    tr (emphasis :: attributes) cells
      

distributeHorizontally contents =
  div [class "level"] contents


controlRow labelText controlPart = 
  div [class "control is-horizontal"]
    [ div [class "control-label"] [label [class "label"] [text labelText]]
    , controlPart
    ]
        
oneReasonablySizedControl control = 
  div [class "control is-grouped"]
    [ p [class "control"]
        [ control
        ]
    ]

horizontalControls controls =
  div [class "control is-grouped"]
    controls

oneTextInputInRow extraAttributes =
  p [class "control"]
    [ input ([ class "input"
            , type_ "text"
            ] ++ extraAttributes)
        []
    ]

soleTextInputInRow fieldValue extraAttributes =
  let
    field =
      input
        ([ class fieldClasses
        , type_ "text"
        , value fieldValue.value
        ] ++ extraAttributes)
        []
      
    oneCommentary (urgency, string) =
      span [ class "help is-danger" ] [ text string ]

    (paragraphClasses, fieldClasses, fieldIcons) = 
      case fieldValue.validity of
        Valid -> ( "control"
                 , "input"
                 , []
                 )
        Invalid -> ( "control has-icon has-icon-right"
                   , "input is-danger"
                   , [i [class "fa fa-warning"] []]
                   )

    contents =
      [ field ] ++ fieldIcons ++ List.map oneCommentary fieldValue.commentary
  in
    oneReasonablySizedControl
      (p [ class paragraphClasses ] contents)
    
textInputWithSubmit buttonLabel fieldValue inputMsg submitMsg =
  div [class "control has-addons"]
    [ oneTextInputInRow
        [ value fieldValue
        , Events.onInput inputMsg
        , onEnter submitMsg
        ]
    , a [ class "button is-success"
        , onClickWithoutPropagation submitMsg
        ]
        [ text buttonLabel ]
    ]


exampleSuccess =
  a
    [ class "button is-success is-small" ]
    [ span [class "icon"] [i [class "fa fa-check"] []]
    , text "Save"
    ]
  
leftwardSuccess enabled msg =
  let
    attributes =
      case enabled of
        True ->
          [ class "button is-success pull-left"
          , onClickWithoutPropagation msg
          ]
        False ->
          [ class "button is-success pull-left is-disabled"
          ]
  in
    p []
      [ a attributes
          [ span [class "icon"] [i [class "fa fa-check"] []]
          , text "Save"
          ]
      ]


rightwardCancel msg = 
  p []
    [ a [ class "button is-danger pull-right"
        , onClickWithoutPropagation msg
        ]
        [ span [class "icon"] [i [class "fa fa-times"] []]
        , text "Cancel"
        ]
    ]

deleteButton msg =
  button
    [ class "delete"
    , Events.onClick msg
    ]
    []
    
flashNotification msg contentList = 
  div [class "notification is-warning"]
    <| deleteButton msg :: contentList

