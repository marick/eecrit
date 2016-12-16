module IV.Clock.AnimatedView exposing ( render
                                      , hourHandStartsAt
                                      , minuteHandStartsAt
                                      )

import IV.Clock.ViewConstants as Clock
import Animation
import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Pile.SvgAttributes exposing (..)


render model =
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
        , markerWidth_ 10
        , markerHeight_ 10
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
  [ x1_ Clock.centerX
  , y1_ Clock.centerY
  , x2_ Clock.centerX
  -- y2 will depend on length of hand
  , stroke "black"
  , markerEnd "url(#arrow)"
  , transformOrigin_ Clock.centerX Clock.centerY
  ]
hourHandBaseProperties =
  [ y2_ (Clock.centerY - Clock.hourHandLength)
  , strokeWidth "5"
  ] ++ handProperties
      
minuteHandBaseProperties =
  [ y2_ (Clock.centerY - Clock.minuteHandLength)
  , strokeWidth "3"
  ] ++ handProperties

