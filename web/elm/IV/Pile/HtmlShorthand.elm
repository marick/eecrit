module IV.Pile.HtmlShorthand exposing (..)

import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events as Events

row attrs elements =
  div ([class "row"] ++ attrs) elements

role = attribute "role"

textInput extraAttributes value onInput =
  input
  ([ type' "text"
   , Attr.value value
   , size 6
   , Events.onInput onInput
   ] ++ extraAttributes)
  []

navChoice label onClick isActive = 
  li
    [ role "presentation"
    , classList [ ("active", isActive) ]
    ]
    [ a [ href "#"
        , Events.onClick onClick
        ]
        [text label]
    ]

launchWhenDoneButton onClick needsWork label = 
  button
  [ Events.onClick onClick
  , type' "button"
  , classList [ ("btn", True)
              , ("btn-primary", not needsWork)
              , ("btn-xs", True)
              ]
  , disabled needsWork
  ]
  [text label]
  
  
displayStyle toShow =
  case toShow of 
    True -> ("display", "block")
    False -> ("display", "none")

greyableText beGrey =
  let
    color = case beGrey of
              True -> "grey"
              False -> "black"
  in
    style [ ("color", color)
          , ("background-color", "white")
          ]


pSimple string =
  p [] [text string ]

rowSimple string =
  row [] [ text string ]
