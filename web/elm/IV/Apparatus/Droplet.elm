module IV.Apparatus.Droplet exposing (..)

import Animation
import IV.Apparatus.DropletView as View
import IV.Types exposing (..)

--- Model

type alias Model =
  { style : Animation.State
  }

noDrips : Model 
noDrips =
  Model (Animation.style View.missingDrop)



animations : Model -> List Animation.State
animations model =
  [model.style]

-- Update

dropStreamCutoff = DropsPerSecond 8.0
guaranteedFlow = DropsPerSecond 10.0
-- Following is slower than reality (in a vacuum), but looks better
fallingTime = asDuration dropStreamCutoff

easing duration =
  Animation.easing
    {
      ease = identity
    , duration = duration
    }

fallingDrop dropsPerSecond =
  let
    totalTime = asDuration dropsPerSecond
    hangingTime = totalTime - fallingTime
  in
    [ Animation.set View.missingDrop
    , Animation.toWith (easing hangingTime) View.hangingDrop
    , Animation.toWith (easing fallingTime) View.fallenDrop
    ]

steadyStream = 
  [ Animation.toWith (easing fallingTime) View.streamState1
  , Animation.toWith (easing fallingTime) View.streamState2
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
  

showTrueFlow model perSecond = 
  { model | style = changeDropRate perSecond model.style }

showTimeLapseFlow model = 
  { model | style = changeDropRate guaranteedFlow model.style }

animationClockTick model tick =     
  { model | style = (Animation.update tick) model.style }

