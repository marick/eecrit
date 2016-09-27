module IV.Clock.View exposing (..)

import Animation
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Formatting exposing (..)
import Html exposing (button, text, div)
import IV.Pile.SvgAttributes exposing (..)
import IV.Msg as TopMsg
import Html.Events as Events

import Color

-- HTML Part

controls =
  div []
    [ button [Events.onClick TopMsg.AdvanceHours ] [ Html.text "Advance Hours"]
    ]

-- Plain Drawing Part

clockCenterX = 260
clockCenterY = 200
clockRadius = 100
hourHandLength = clockRadius // 3
minuteHandLength = 2 * clockRadius // 3
traceLineLength = 80
clockNumeralOffset = 10
clockNumeralSize = "20px"

defineArrowhead = 
  defs
    []
    [ marker
        [ id "arrow"
        , markerWidth' 10
        , markerHeight' 10
        , refX "0"
        , refY "3"
        , orient "auto"
        , markerUnits "strokeWidth"]
        [ Svg.path
            [ d "M0,0 L0,6 L9,3 z"
            , fill "#f00"
            ]
            []
        ]
    ]

spacedInt = s " " <> int <> s " "

rotate' degrees xCenter yCenter =
  let
    fmt = s "rotate(" <> spacedInt <> spacedInt <> spacedInt <> s ")"
  in
    print fmt degrees xCenter yCenter
      
transformForHour hour =
  transform <| rotate' (hour * 30) clockCenterX clockCenterY

clockNumeral value = 
  let    
    common =
      [ fontSize clockNumeralSize
      , dy ".3em"  -- apparently better methods don't work on IE
      , textAnchor "middle"]
    xy =
      case value of
        12 ->
          [ x' clockCenterX
          , y' (clockCenterY - clockRadius + clockNumeralOffset)
          ]
        3 ->
          [ x' (clockCenterX + clockRadius - clockNumeralOffset )
          , y' clockCenterY
          ]
        6 ->
          [ x' clockCenterX
          , y' (clockCenterY + clockRadius - clockNumeralOffset)
          ]
        9 -> 
          [ x' (clockCenterX - clockRadius + clockNumeralOffset )
          , y' clockCenterY
          ]
        _ ->
          []
          
  in
    Svg.text' (common ++ xy) [Svg.text <| toString value]
      
face =
  g []
    ([ circle
       [ cx' clockCenterX
       , cy' clockCenterY
       , r' clockRadius
       , fill "#0B79CE" 
       ]
       []
     , defineArrowhead
     , clockNumeral 12
     , clockNumeral 3
     , clockNumeral 6
     , clockNumeral 9
     ] ++ (List.map trace [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]))
  
trace hour = 
  line
    [ x1' clockCenterX
    , y1' clockCenterY
    , x2' clockCenterX
    , y2' (clockCenterY - traceLineLength)
    , stroke "#000"
    , strokeWidth "1"
    , transformForHour hour
    ]
    []

-- Animation Part

handProperties =
  [ x1' clockCenterX
  , y1' clockCenterY
  , x2' clockCenterX
  -- y2 will depend on length of hand
  , stroke "black"
  , markerEnd "url(#arrow)"
  , transformOrigin' clockCenterX clockCenterY
  ]
hourHandBaseProperties =
  [ y2' (clockCenterY - hourHandLength)
  , strokeWidth "5"
  ] ++ handProperties
      
minuteHandBaseProperties =
  [ y2' (clockCenterY - minuteHandLength)
  , strokeWidth "3"
  ] ++ handProperties

hourHandStartsAt hour =
  [
    Animation.rotate (Animation.deg (30 * hour))
  ]

minuteHandStartsAt minute =
  [
    Animation.rotate (Animation.deg minute)
  ]

render model =
  Svg.g []
    [ line (Animation.render model.hourHand ++ hourHandBaseProperties) []
    , line (Animation.render model.minuteHand ++ minuteHandBaseProperties) []
    ]
