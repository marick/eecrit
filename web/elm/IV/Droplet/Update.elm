module IV.Droplet.Update exposing (..)

import Animation
import IV.Droplet.Msg exposing (Msg(..))
import IV.Droplet.Model as Model exposing (Model)
import IV.Droplet.View as View
import Time exposing (second)
import IV.Types exposing (..)

dropStreamCutoff = (DropsPerSecond 8.0)
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
  [ -- Animation.set View.missingDrop
    Animation.toWith (easing fallingTime) View.streamState1
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
  
  

update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangeDripRate perSecond ->
      { model | style = changeDropRate perSecond model.style }

    AnimationClockTick tick ->
      { model | style = (Animation.update tick) model.style }


