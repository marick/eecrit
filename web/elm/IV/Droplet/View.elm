module IV.Droplet.View exposing (..)

import Animation
import IV.Palette as Palette
import Svg

starting = [ Animation.points
                       [ ( 55, 200 )
                       , ( 65, 200)
                       , ( 65, 210 )
                       , ( 55, 210 )
                       ]
           , Animation.fill Palette.white
           ]

growing = [ Animation.points
                       [ ( 55, 200 )
                       , ( 65, 200)
                       , ( 65, 210 )
                       , ( 55, 210 )
                       ]
           , Animation.fill Palette.aluminum
           ]

stopping = [ Animation.points
                       [ ( 55, 290 )
                       , ( 65, 290)
                       , ( 65, 300 )
                       , ( 55, 300 )
                       ]
           ]

render model =
  Svg.polygon (Animation.render model.style) []

