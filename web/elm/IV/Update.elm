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
    ChangeDripRate ->
      ( { model
          | droplet = Droplet.update (DropletMsg.ChangeDripRate model.speedControl.float) model.droplet }
      , Cmd.none
        )

    ChangedTextField nextString ->
      ( { model
          | speedControl = SpeedControl.update (SpeedMsg.ChangedTextField nextString) model.speedControl
        }
      , Cmd.none)

    AnimationClockTick tick ->
      ( { model
          | droplet = Droplet.update (DropletMsg.AnimationClockTick tick) model.droplet 
        }
      , Cmd.none
      )

