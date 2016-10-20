module IV.Clock.StaticView exposing (render)

import IV.Clock.ViewConstants as Clock
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Formatting exposing (..)
import IV.Pile.SvgAttributes exposing (..)

render =
  g []
    ([ circle
       [ cx' Clock.centerX
       , cy' Clock.centerY
       , r' Clock.radius
       , fill "#0B79CE" 
       ]
       []
     , clockNumeral 12
     , clockNumeral 3
     , clockNumeral 6
     , clockNumeral 9
     ] ++ (List.map hourMarkers [12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]))

-- Private


spacedInt = s " " <> int <> s " "

rotate' degrees xCenter yCenter =
  let
    fmt = s "rotate(" <> spacedInt <> spacedInt <> spacedInt <> s ")"
  in
    print fmt degrees xCenter yCenter
      
transformForHour hour =
  transform <| rotate' (hour * 30) Clock.centerX Clock.centerY
      
hourMarkers hour = 
  line
    [ x1' Clock.centerX
    , y1' Clock.centerY
    , x2' Clock.centerX
    , y2' (Clock.centerY - Clock.hourMarkersLineLength)
    , stroke "#000"
    , strokeWidth "1"
    , transformForHour hour
    ]
    []

clockNumeral value = 
  let    
    common =
      [ fontSize Clock.numeralFontSize
      , dy ".3em"  -- apparently better methods don't work on IE
      , textAnchor "middle"]
    xy =
      case value of
        12 ->
          [ x' Clock.centerX
          , y' (Clock.centerY - Clock.radius + Clock.numeralOffset)
          ]
        3 ->
          [ x' (Clock.centerX + Clock.radius - Clock.numeralOffset )
          , y' Clock.centerY
          ]
        6 ->
          [ x' Clock.centerX
          , y' (Clock.centerY + Clock.radius - Clock.numeralOffset)
          ]
        9 -> 
          [ x' (Clock.centerX - Clock.radius + Clock.numeralOffset )
          , y' Clock.centerY
          ]
        _ ->
          []
          
  in
    Svg.text' (common ++ xy) [Svg.text <| toString value]
      

