module IV.Scenario.Editor exposing
  (..)

import Html exposing (..)
import Html.Attributes as Attr
import IV.Msg as MainMsg
import Html.Events as Events
import IV.Pile.HtmlShorthand exposing (..)
import IV.Scenario.Models exposing (EditableModel)


edit : EditableModel -> Html MainMsg.Msg
edit model = 
  row
    [ Attr.style
        [ ("border", "2px solid #AAA")
        , ( "opacity", "0" )
        , ( "height", "0px" )
        ]
    ]
    [ text "here is some text" ]

    
