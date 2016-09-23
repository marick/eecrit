module IV.Droplet.Update exposing (..)

import Animation
import IV.Droplet.Msg exposing (Msg(..))
import IV.Droplet.Model as Model exposing (Model)
import IV.Droplet.View as View
import Time exposing (second)


update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangeDripRate v -> 
      let
        -- Will use new mechanism for this shortly
        tempSpeed = Animation.speed {perSecond = v}
        newCommands = [
         Animation.loop
           [
            Animation.wait (0.05 * second)
           , Animation.toWith tempSpeed View.growing
           , Animation.wait (0.1 * second)
           , Animation.toWith tempSpeed View.stopping
           , Animation.set View.starting
           ]
        ]
      in
        { model | style = Animation.interrupt newCommands (Model.animation model)}

    AnimationClockTick tick ->
      { model | style = (Animation.update tick) (Model.animation model) }
