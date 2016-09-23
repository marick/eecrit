module IV.Update exposing (update)

import IV.Msg exposing (Msg(..))
import IV.Model exposing (Model)
import String
import IV.Droplet.Update as Droplet
import IV.SpeedControl.Update as SpeedControl
import IV.Droplet.Msg as DropletMsg
import IV.SpeedControl.Msg as SpeedMsg

startAnimation model = 
  { model | droplet = Droplet.update (DropletMsg.ChangeDripRate model.currentSpeed) model.droplet }

    

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToSpeedControl msg' ->
      ( { model | speedControl = SpeedControl.update msg' model.speedControl }
      , Cmd.none
      )

    ChangeDripRate ->
      ( { model
          | droplet = Droplet.update (DropletMsg.ChangeDripRate model.speedControl.float) model.droplet }
      , Cmd.none
        )

    AnimationClockTick tick ->
      let
        updater = (DropletMsg.AnimationClockTick tick)
      in
        ( { model
            | droplet = Droplet.update updater model.droplet 
          }
        , Cmd.none
        )

