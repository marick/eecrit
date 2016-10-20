module IV.Apparatus.DropletView exposing ( render
                                         , missingDrop
                                         , hangingDrop
                                         , fallenDrop
                                         , streamState1
                                         , streamState2
                                         )

import Animation
import Svg
import IV.Types exposing (..)
import IV.Apparatus.ViewConstants as Apparatus

render model =
  Svg.polygon (Animation.render model.style) []

missingDrop =
  [ Animation.points dropAtTop
  , Animation.fill Apparatus.whiteColor
  ]

hangingDrop =
  [ Animation.points dropAtTop
  , Animation.fill Apparatus.liquidColor
  ]

fallenDrop =
  [ Animation.points dropInFluidAtBottom ]

streamState1 =
  [ Animation.points flowInChamber
  , Animation.fill Apparatus.liquidColor
  ]    
      
streamState2 =
  [ Animation.points flowInChamber
  , Animation.fill Apparatus.variantLiquidColor
  ]    
      

-- Private

translateBy : Point -> List Point -> List Point
translateBy (deltaX, deltaY) points =
  List.map (\(x, y) -> (x + deltaX, y + deltaY)) points
  

dropShape = 
  [ ( 0,                   0 )
  , ( Apparatus.dropWidth, 0)
  , ( Apparatus.dropWidth, Apparatus.dropHeight )
  , ( 0,                   Apparatus.dropHeight )
  ]

flowShape = 
    [ ( 0,                   0)
    , ( Apparatus.dropWidth, 0)
    , ( Apparatus.dropWidth, Apparatus.streamHeight)
    , ( 0,                   Apparatus.streamHeight)
    ]


dropAtTop =
  translateBy
    (Apparatus.dropXOffset, Apparatus.chamberYOffset)
    dropShape

dropInFluidAtBottom =
  translateBy
    (Apparatus.dropXOffset, Apparatus.puddleYOffset)
    dropShape

flowInChamber =
  translateBy
    (Apparatus.dropXOffset, Apparatus.chamberYOffset)
    flowShape

                      
