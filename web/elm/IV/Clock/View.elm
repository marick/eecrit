module IV.Clock.View exposing
  ( view
  , hourHandStartsAt
  , minuteHandStartsAt
  )

import Animation
import Formatting exposing (..)
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
  Svg.g [ ]
    [ defineArrowhead
    , line (Animation.render model.hourHand ++ hourHandBaseProperties) []
    , line (Animation.render model.minuteHand ++ minuteHandBaseProperties) []
    ]

-- TODO: It's annoying that the clock center has to be set here, rather than
-- with the static properties. However, I don't see the right way to combine
-- a `style = "transform-origin: 260px 200px"` there with the rotation
-- transform here. It must be something stupid. 
    
hourHandStartsAt hour =
  [ originAtClockCenter
  , Animation.rotate (Animation.deg (30 * hour))
  ]

minuteHandStartsAt minute =
  [ originAtClockCenter
  , Animation.rotate (Animation.deg minute)
  ]

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

originAtClockCenter =
  let 
    argFormatter = print <| int <> s "px " <> int <> s "px"
  in
    Animation.exactly "transform-origin" <| argFormatter Clock.centerX Clock.centerY


handProperties =
  [ x1_ Clock.centerX
  , y1_ Clock.centerY
  , x2_ Clock.centerX
  -- y2 will depend on length of hand
  , stroke "black"
  , markerEnd "url(#arrow)"
  ]
hourHandBaseProperties =
  [ y2_ (Clock.centerY - Clock.hourHandLength)
  , strokeWidth "5"
  ] ++ handProperties
      
minuteHandBaseProperties =
  [ y2_ (Clock.centerY - Clock.minuteHandLength)
  , strokeWidth "3"
  ] ++ handProperties

