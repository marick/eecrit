module IV.Clock.View exposing (..)

import Animation
import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Palette as Palette
import Dict
import Formatting exposing (..)

import Color

useInt : (String -> a) -> (Int -> a)
useInt stringFn i =
  i |> (print int) |> stringFn


markerWidth' = useInt markerWidth
markerHeight' = useInt markerHeight
x' = useInt x
x1' = useInt x1
x2' = useInt x2
y' = useInt y
y1' = useInt y1
y2' = useInt y2
cx' = useInt cx
cy' = useInt cy
r' = useInt r

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

minuteHandAt hour =
  line
    [ x1' clockCenterX
    , y1' clockCenterY
    , x2' clockCenterX
    , y2' (clockCenterY - minuteHandLength)
    , stroke "#000"
    , strokeWidth "3"
    , markerEnd "url(#arrow)"
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
    text' (common ++ xy) [text <| toString value]
      
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

hourHandBaseProperties hour =
  [ x1' clockCenterX
  , y1' clockCenterY
  , x2' clockCenterX
  , y2' (clockCenterY - hourHandLength)
  , stroke "#000"
  , strokeWidth "3"
  , markerEnd "url(#arrow)"
  , transformForHour hour
  ]
      
startingHourHandProperties =
  [Animation.stroke Color.blue,
   Animation.strokeWidth 1.0]

endingHourHandProperties =
  [Animation.stroke Color.red,
   Animation.strokeWidth 10.0]
  
render model =
  line (Animation.render model.style ++ hourHandBaseProperties 2) []
