module IV.View.MainPage exposing (view)

import Animation
import Html exposing (..)
import Html.Attributes exposing (..)
import Svg
import Svg.Attributes as SA
import Vendor
import IV.Pile.HtmlShorthand exposing (..)

import IV.View.Layout as Layout
import IV.Main exposing (Model)
import IV.Msg exposing (Msg(..))
import IV.Scenario.View as Scenario
import IV.Apparatus.View as Apparatus
import IV.Clock.View as Clock

graphics = {width = "400px", height = "400px"}


mainSvg contents  =
  row [] 
    [ Svg.svg
        [ SA.version "1.1"
        , SA.x "0"
        , SA.y "0"
        , SA.width graphics.width
        , SA.height graphics.height
        ]
        contents
    ]

view : Model -> Html Msg
view model =
  div []
    [ Layout.headerWith (Scenario.viewScenarioChoices model.scenario)
    , Scenario.viewCaseBackgroundEditor model.scenario
    , div [class "row" ]
        [ div [ class "col-sm-6" ]
            [ mainSvg (Apparatus.view model.apparatus ++ Clock.view model.clock)
            ]
        , div [ class "col-sm-6" ]
          [ Scenario.viewTreatmentEditor model.scenario
          ]
        ]
    , Layout.footerWith aboutThisBrowser Layout.defaultFooterNav
    ]


aboutThisBrowser =
  let
    letMeKnow = a [ type_ "button"
                  , class "btn btn-default btn-xs"
                  , href "mailto:marick@roundingpegs.com?subject=Browser%20report"
                  ]
                [ text "let me know" ]
                     
    default = [ text "Note: I don't know if the drawing or animation "
              , text "will work on your browser. If it does, "
              , letMeKnow
              ]
    body =
      case Vendor.prefix of
        Vendor.Webkit ->
          [ text "Note: "
          , text "This app's animation is known to work on the latest version of your browser. "
          , text "If you are having problems, you can try upgrading."
          ]
        Vendor.Moz ->
          [ span [style [("color", "red")]]
              [ text "This app's drawing and animation is known "
              , b [] [text "not"]
              , text " to work on the Macintosh version of Firefox, and it "
              , text " probably doesn't work on any version. If it "
              , b [] [text "does"]
              , text " work, "
              , letMeKnow
              ]
          ] 
        Vendor.MS ->
          [ text "Note: I don't have a Windows computer, so I don't know if "
          , text "this will work with your browser. If it does, "
          , letMeKnow
          ]
        _ ->
          default
  in
    row [ class "col-sm-12" ] body
