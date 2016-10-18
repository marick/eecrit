module IV.Clock.ClockFace exposing (drawing)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import Formatting exposing (..)
import IV.Pile.SvgAttributes exposing (..)


-- Todo: remove this duplication
clockCenterX = 260
clockCenterY = 200
clockRadius = 100

clockNumeralOffset = 10
clockNumeralSize = "20px"
hourMarkersLineLength = 80

drawing =
  g []
    ([ circle
       [ cx' clockCenterX
       , cy' clockCenterY
       , r' clockRadius
       , fill "#0B79CE" 
       ]
       []
     , clockNumeral 12
     , clockNumeral 3
     , clockNumeral 6
     , clockNumeral 9
     ] ++ (List.map hourMarkers [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]))

spacedInt = s " " <> int <> s " "

rotate' degrees xCenter yCenter =
  let
    fmt = s "rotate(" <> spacedInt <> spacedInt <> spacedInt <> s ")"
  in
    print fmt degrees xCenter yCenter
      
transformForHour hour =
  transform <| rotate' (hour * 30) clockCenterX clockCenterY
      
hourMarkers hour = 
  line
    [ x1' clockCenterX
    , y1' clockCenterY
    , x2' clockCenterX
    , y2' (clockCenterY - hourMarkersLineLength)
    , stroke "#000"
    , strokeWidth "1"
    , transformForHour hour
    ]
    []

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
      

