module Pile.Css.Bulma exposing (..)

import Pile.Css.H exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.HtmlShorthand exposing (..)
import Maybe.Extra as Maybe

adjustClassForStatus : FormStatus -> String -> String
adjustClassForStatus status classes =
  if status == BeingSaved then
    classes ++ " is-disabled"
  else
    classes

tab : page -> ( page, String, msg ) -> Html msg
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
        , onClickPreventingDefault msg
        ]
       [ span [class spanClass] [text linkText] ]
    ]
    
                   
tabs : page -> List ( page, String, msg ) -> Html msg
tabs selectedPage tabList =
  div [class "tabs is-centered is-toggle"]
    [ ul [] <| List.map (tab selectedPage) tabList
    ]

shortenWidth : List (Html msg) -> Html msg
shortenWidth content =
  div [class "columns is-centered is-mobile"]
    [ div [class "column is-10 has-text-centered"]
        content
    ] 

message : String -> String -> String -> Html msg
message kind header body =
  shortenWidth
    [ article [class <| "message " ++ kind ]
        [ div [ class "message-header" ] [ text header ] 
        , div [ class "message-body"] [ text body ]
        ]
    ]

infoMessage : String -> String -> Html msg
infoMessage = message "is-info"

type alias IconExpander msg = String -> String -> msg -> Html msg
              
tdIcon : String -> String -> msg -> Html msg
tdIcon iconSymbolName tooltip msg =
  td [class "is-icon"]
    [a [ href "#"
       , title tooltip
       , onClickPreventingDefault msg
       ]
       [i [class ("fa " ++ iconSymbolName)] []]
    ]

plainIcon : String -> String -> msg -> Html msg
plainIcon iconSymbolName tooltip msg =
  a [ href "#"
    , class "icon"
    , title tooltip
    , onClickPreventingDefault msg
    ]
    [i [class ("fa " ++ iconSymbolName)] []]

    
rightIcon : String -> String -> msg -> Html msg
rightIcon iconSymbolName tooltip msg =
  a [ href "#"
    , class "icon is-pulled-right"
    , title tooltip
    , onClickPreventingDefault msg
    ]
    [i [class ("fa " ++ iconSymbolName)] []]

coloredIcon : String -> String -> Html msg
coloredIcon iconName color =
  i [class ("fa " ++ iconName)
    , style [("color", color)]
    ] []

trueIcon : Html msg
trueIcon = coloredIcon "fa-check" "green"

falseIcon : Html msg
falseIcon = coloredIcon "fa-times" "red"
              
readOnlyTag : String -> Html msg
readOnlyTag tagText =
  span [ class "tag" ] [ text tagText ]
    
deletableTag : FormStatus -> (String -> a) -> String -> Html a
deletableTag status msg tagText =
  if status == BeingSaved then
    readOnlyTag tagText
  else
    p [ class "tag is-primary control" ]
      [ text tagText
      , button
          [ class "delete"
          , Events.onClick (msg tagText)
          ] []
      ]
    
messageView : List (Html msg) -> List (Html msg) -> Html msg
messageView headerList contentList  =
  article [class "message"]
    [ div [class "message-header has-text-centered"] headerList
    , div [class "message-body"] contentList
    ]

centeredLevelItem : List (Html msg) -> Html msg
centeredLevelItem content =
  div [class "level-item has-text-centered"]
    content

simpleSelect : List (Html msg) -> Html msg
simpleSelect content = 
  span [ class "select" ]
    [ select [] content ]

disabledSelect : List (Html msg) -> Html msg
disabledSelect content = 
  span [ class "select" ]
    [ select [disabled True] content ]

headingP : String -> Html msg
headingP heading = 
  p [class "heading"] [text heading]

simpleTextInput : String -> (String -> msg) -> Html msg
simpleTextInput val msg = 
  p [class "control"]
    [input
       [ class "input"
       , type_ "text"
       , value val
       , Events.onInput msg]
       []
    ]

centeredColumns : List (Html msg) -> Html msg
centeredColumns contents =
  div [class "columns is-centered"] contents

column : Int -> List (Html msg) -> Html msg
column n contents =
  div [class ("column is-" ++ (toString n))] contents



headerlessTable : List (Html msg) -> Html msg
headerlessTable body = 
  table [class "table"]
    [ tbody [] body ]

propertyTable : List (Html msg) -> Html msg
propertyTable body = 
  table [ style [("width", "auto")]
        , class "table is-bordered"
        ]
    [ tbody [] body ]

highlightedRow : List (Attribute msg) -> List (Html msg) -> Html msg
highlightedRow attributes cells =
  let
    emphasis = style [ ("border-top", "2px solid")
                     , ("border-bottom", "2px solid")
                     ]
  in
    tr (emphasis :: attributes) cells
      
distributeHorizontally : List (Html msg) -> Html msg
distributeHorizontally contents =
  div [class "level"] contents


controlRow : String -> Html msg -> Html msg
controlRow labelText controlPart = 
  div [class "control is-horizontal"]
    [ div [class "control-label"] [label [class "label"] [text labelText]]
    , controlPart
    ]
        
horizontalControls : List (Html msg) -> Html msg    
horizontalControls controls =
  div [class "control is-grouped"]
    controls

oneTextInputInRow : List (Attribute msg) -> Html msg
oneTextInputInRow extraAttributes =
  p [class "control"]
    [ input ([ class "input"
            , type_ "text"
            ] ++ extraAttributes)
        []
    ]



textInputWithSubmit : FormStatus -> String -> String -> (String -> msg) -> msg
                    -> Html msg
textInputWithSubmit formStatus buttonLabel fieldValue inputMsg submitMsg =
  div [class "control has-addons"]
    [ p [class "control"]
        [ input [ class <| adjustClassForStatus formStatus "input"
                , type_ "text"
                , value fieldValue
                , Events.onInput inputMsg
                , onEnter submitMsg
                ] []
        ]
    , a [ class <| adjustClassForStatus formStatus "button is-success"
        , onClickPreventingDefault submitMsg
        ]
        [ text buttonLabel ]
    ]

exampleSuccess : Html msg
exampleSuccess =
  a
    [ class "button is-success is-small" ]
    [ span [class "icon"] [i [class "fa fa-check"] []]
    , text "Save"
    ]

leftwardSave : FormStatus -> msg -> Html msg
leftwardSave status msg =
  let
    universalClasses = "button is-success pull-left"
    attributes =
      case status of
        AllGood ->
          [ class universalClasses
          , onClickPreventingDefault msg
          ]
        SomeBad ->
          [ class <| universalClasses ++ " is-disabled"
          ]
        BeingSaved ->
          [ class <| universalClasses ++ " is-loading"
          ]
  in
    p []
      [ a attributes
          [ span [class "icon"] [i [class "fa fa-check"] []]
          , text "Save"
          ]
      ]

rightwardCancel : FormStatus -> msg -> Html msg
rightwardCancel status msg =
  p []
    [ a [ class <| adjustClassForStatus status "button is-danger pull-right"
        , onClickPreventingDefault msg
        ]
        [ span [class "icon"] [i [class "fa fa-times"] []]
        , text "Cancel"
        ]
    ]
    
deleteButton : msg -> Html msg
deleteButton msg =
  button
    [ class "delete"
    , Events.onClick msg
    ]
    []

flashNotification : msg -> List (Html msg) -> Html msg      
flashNotification msg contentList = 
  div [class "notification is-warning"]
    <| deleteButton msg :: contentList
