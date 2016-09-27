module IV.View.Apparatus exposing (drawing)

import Svg exposing (..)
import Svg.Attributes exposing (..)
import IV.Clock.View as Clock

drawing =
  Svg.g [] [liquid, bottomLiquid, bag, nozzle, hose]

bag = rect
      [ fill "none"
      , x "0"
      , y "0"
      , width "120"
      , height "199"
      , stroke "black"
      ]
      []

liquid = rect
      [ fill "#d3d7cf"
      , x "0"
      , y "20"
      , width "120"
      , height "179"
      ]
      []

nozzle = polyline
         [ fill "none", stroke "black", points "45,200 45,290 75,290 75,200"]
         []

bottomLiquid = polygon
               [ fill "#d3d7cf"
               , points "45,270 45,290 75,290 75,270"
               ]
               []
           
hose =
  Svg.rect
    [ stroke "black"
    , fill "#d3d7cf"
    , x "55"
    , y "290"
    , width "10"
    , height "90"
    ]
    []
