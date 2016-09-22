module IV.StaticImage exposing (provideBackdropFor)

import Svg exposing (..)
import Svg.Attributes exposing (..)

provideBackdropFor animatedElements = 
  svg
    [ version "1.1"
    , x "0"
    , y "0"
    , viewBox "0 0 400 400"
    ]
    <| [liquid, bottomLiquid, bag, nozzle] ++ animatedElements

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
         [ fill "none", stroke "black", points "40,200 45,330 75,330 80,200"]
         []

bottomLiquid = polygon
               [ fill "#d3d7cf"
               , points "43,290 45,330 75,330 77,290"
               ]
               []
           

