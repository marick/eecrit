module IV.Droplet.View exposing (..)

import Animation
import IV.Palette as Palette
import Svg

type alias Point = (Float, Float)

translateBy : Point -> List Point -> List Point
translateBy (deltaX, deltaY) points =
  List.map (\(x, y) -> (x + deltaX, y + deltaY)) points
  
dropWidth = 10
dropHeight = 10
flowHeight = 70

dropShape = 
  [ ( 0,         0 )
  , ( dropWidth, 0)
  , ( dropWidth, dropHeight )
  , ( 0,         dropHeight )
  ]

flowShape = 
    [ ( 0,         0)
    , ( dropWidth, 0)
    , ( dropWidth, flowHeight)
    , ( 0,         flowHeight)
    ]

chamberXOffset = 55
chamberYOffset = 200
fluidYOffset = 270

dropAtTop = translateBy (chamberXOffset, chamberYOffset) dropShape
dropInFluidAtBottom = translateBy (chamberXOffset, fluidYOffset) dropShape

flowInChamber = translateBy (chamberXOffset, chamberYOffset) flowShape

                      
missingDrop =
  [ Animation.points dropAtTop
  , Animation.fill Palette.white
  ]

hangingDrop =
  [ Animation.points dropAtTop
  , Animation.fill Palette.aluminum
  ]

fallenDrop =
  [ Animation.points dropInFluidAtBottom ]

streamState1 =
  [ Animation.points flowInChamber
  , Animation.fill Palette.aluminum
  ]    
      
streamState2 =
  [ Animation.points flowInChamber
  , Animation.fill Palette.shiftedAluminum
  ]    
      
render model =
  Svg.polygon (Animation.render model.style) []
