module IV.View.Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import IV.Pile.HtmlShorthand exposing (..)

import IV.Main exposing (Model)
import IV.Msg exposing (Msg(..))
import IV.Version as Version


headerWith navs =
  div [class "header clearfix"]
    [ nav []
        [ ul [ class "nav nav-pills pull-right" ] navs ]
    , h3 [class "text-muted"] [text "IV Worksheet"]
    ]


footerWith prefix navs =
  footer [class "footer"] 
    [ hr [] []
    , prefix
    , nav []
        [ ul [ class "nav nav-pills pull-right" ] navs]
    ]
    


defaultFooterNav =
  [ navElement
      [ a [ href "/iv/about"
          , onClickWithoutPropagation NavigateToAboutPage
          ]
          [text "About and Disclaimer"]
      ]
  , navElement
      [ a [ href Version.source ]
          [ text Version.text ]
      ]
  ]
