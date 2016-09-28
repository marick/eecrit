module IV.Clock.View exposing (..)

import Animation
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Html exposing (button, text, div, label)
import IV.Pile.SvgAttributes exposing (..)
import IV.Msg as TopMsg
import Html.Events as Events


-- HTML Part: Controlling the model

controls =
  div
    [ class "form-group" ]
    [ label [ class "control-label"] [ Html.text "Control the clock" ]
    , button
        [ Events.onClick TopMsg.AdvanceHours
        , class "btn btn-default btn-xs"
        ]
        [ Html.text "Advance Hours"]
    ]

-- Drawing Part: Displaying the model

clockCenterX = 260
clockCenterY = 200
clockRadius = 100
hourHandLength = clockRadius // 3
minuteHandLength = 2 * clockRadius // 3

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
  [Animation.rotate (Animation.deg (30 * hour))]

minuteHandStartsAt minute =
  [Animation.rotate (Animation.deg minute)]

render model =
  Svg.g []
    [ defineArrowhead
    , line (Animation.render model.hourHand ++ hourHandBaseProperties) []
    , line (Animation.render model.minuteHand ++ minuteHandBaseProperties) []
    ]
