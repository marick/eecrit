module IV.Apparatus.Droplet exposing (..)

import Animation
import Animation.Messenger
import IV.Apparatus.DropletView as View
import IV.Types exposing (..)
import IV.Msg exposing (Msg)
import IV.Pile.Animation exposing (linearEasing)

--- Model

noDrips : AnimationState 
noDrips =
  Animation.style View.missingDrop

-- Update

dropStreamCutoff = DropsPerSecond 8.0
guaranteedFlow = DropsPerSecond 10.0
-- Following is slower than reality (in a vacuum), but looks better
fallingTime = asDuration dropStreamCutoff

fallingDrop dropsPerSecond =
  let
    totalTime = asDuration dropsPerSecond
    hangingTime = totalTime - fallingTime
  in
    [ Animation.set View.missingDrop
    , Animation.toWith (linearEasing hangingTime) View.hangingDrop
    , Animation.toWith (linearEasing fallingTime) View.fallenDrop
    ]

steadyStream = 
  [ Animation.toWith (linearEasing fallingTime) View.streamState1
  , Animation.toWith (linearEasing fallingTime) View.streamState2
  ]
    
animationSteps dropsPerSecond =
  let
    (DropsPerSecond raw) = dropsPerSecond
  in 
    if raw > 8.0 then
      steadyStream
    else
      fallingDrop dropsPerSecond

changeDropRate dropsPerSecond animation =
  let
    loop = Animation.loop (animationSteps dropsPerSecond)
  in
    Animation.interrupt [loop] animation

showTrueFlow perSecond model =
  ( changeDropRate perSecond model
  , Cmd.none
  )

showTimeLapseFlow model = 
  ( changeDropRate guaranteedFlow model
  , Cmd.none
  )

animationClockTick tick model =
  Animation.Messenger.update tick model
