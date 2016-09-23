module IV.Droplet.Update exposing (..)

import Animation
import IV.Droplet.Msg exposing (Msg(..))
import IV.Droplet.Model as Model exposing (Model)
import IV.Droplet.View as View
import Time exposing (second)
import IV.Types exposing (..)

update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangeDripRate perSecond -> 
      let
        half_x =
          Animation.easing
            {
              ease = identity,
                duration = asDuration(perSecond) / 2.0
            }
        newCommands = [
         Animation.loop
           [ Animation.toWith half_x View.growing
           , Animation.toWith half_x View.stopping
           , Animation.set View.starting
           ]
        ]
      in
        { model | style = Animation.interrupt newCommands (Model.animation model)}

    AnimationClockTick tick ->
      { model | style = (Animation.update tick) (Model.animation model) }
