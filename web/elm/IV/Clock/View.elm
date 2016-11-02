module IV.Clock.View exposing
  ( view
  , hourHandStartsAt
  , minuteHandStartsAt
  )

import Animation
import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Pile.SvgAttributes exposing (..)

import IV.Clock.Face as Face
import IV.Clock.ViewConstants as Clock

view model =
  [ Face.view -- must come first to serve as a background
  , viewHands model
  ]

viewHands model =
  Svg.g []
    [ defineArrowhead
    , line (Animation.render model.hourHand ++ hourHandBaseProperties) []
    , line (Animation.render model.minuteHand ++ minuteHandBaseProperties) []
    ]

hourHandStartsAt hour =
  [Animation.rotate (Animation.deg (30 * hour))]

minuteHandStartsAt minute =
  [Animation.rotate (Animation.deg minute)]

-- Private

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
  [ x1' Clock.centerX
  , y1' Clock.centerY
  , x2' Clock.centerX
  -- y2 will depend on length of hand
  , stroke "black"
  , markerEnd "url(#arrow)"
  , transformOrigin' Clock.centerX Clock.centerY
  ]
hourHandBaseProperties =
  [ y2' (Clock.centerY - Clock.hourHandLength)
  , strokeWidth "5"
  ] ++ handProperties
      
minuteHandBaseProperties =
  [ y2' (Clock.centerY - Clock.minuteHandLength)
  , strokeWidth "3"
  ] ++ handProperties

