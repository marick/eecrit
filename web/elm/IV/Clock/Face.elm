module IV.Clock.Face exposing (view)

import IV.Clock.ViewConstants as Clock
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Formatting exposing (..)
import IV.Pile.SvgAttributes exposing (..)

view =
  g []
    ([ circle
       [ cx_ Clock.centerX
       , cy_ Clock.centerY
       , r_ Clock.radius
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

rotate_ degrees xCenter yCenter =
  let
    fmt = s "rotate(" <> spacedInt <> spacedInt <> spacedInt <> s ")"
  in
    print fmt degrees xCenter yCenter
      
transformForHour hour =
  transform <| rotate_ (hour * 30) Clock.centerX Clock.centerY
      
hourMarkers hour = 
  line
    [ x1_ Clock.centerX
    , y1_ Clock.centerY
    , x2_ Clock.centerX
    , y2_ (Clock.centerY - Clock.hourMarkersLineLength)
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
          [ x_ Clock.centerX
          , y_ (Clock.centerY - Clock.radius + Clock.numeralOffset)
          ]
        3 ->
          [ x_ (Clock.centerX + Clock.radius - Clock.numeralOffset )
          , y_ Clock.centerY
          ]
        6 ->
          [ x_ Clock.centerX
          , y_ (Clock.centerY + Clock.radius - Clock.numeralOffset)
          ]
        9 -> 
          [ x_ (Clock.centerX - Clock.radius + Clock.numeralOffset )
          , y_ Clock.centerY
          ]
        _ ->
          []
          
  in
    Svg.text_ (common ++ xy) [Svg.text <| toString value]
      

