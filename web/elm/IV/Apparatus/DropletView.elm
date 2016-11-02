module IV.Apparatus.DropletView exposing ( view
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

view model =
  Svg.polygon (Animation.render model) []

missingDrop =
  [ Animation.points dropAtTop
  , Animation.fill Apparatus.whiteColor
  ]

hangingDrop =
  [ Animation.points dropAtTop
  , Animation.fill Apparatus.fluidColor
  ]

fallenDrop =
  [ Animation.points dropInFluidAtBottom ]

streamState1 =
  [ Animation.points flowInChamber
  , Animation.fill Apparatus.fluidColor
  ]    
      
streamState2 =
  [ Animation.points flowInChamber
  , Animation.fill Apparatus.variantFluidColor
  ]    
      
streamRunsOut =
  [ Animation.points finalSliverInChamber
  , Animation.fill Apparatus.fluidColor
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

finalSliverOfFlowShape = 
    [ ( 0,                   0)
    , ( Apparatus.dropWidth, 0)
    , ( Apparatus.dropWidth, 0)
    , ( 0,                   0)
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

finalSliverInChamber =
  translateBy
    (Apparatus.dropXOffset, Apparatus.chamberYOffset)
    finalSliverOfFlowShape
