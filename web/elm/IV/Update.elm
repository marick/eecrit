module IV.Update exposing (update)

import IV.Msg exposing (Msg(..))
import IV.Model exposing (Model)
import String
import IV.Droplet.Main as Droplet
import IV.SpeedControl.Update as SpeedControl
import IV.Clock.Update as Clock
import IV.Droplet.Msg as DropletMsg
import IV.SpeedControl.Msg as SpeedMsg
import IV.Clock.Msg as ClockMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    ToSpeedControl msg' ->
      ( { model | speedControl = SpeedControl.update msg' model.speedControl }
      , Cmd.none
      )

    AdvanceHours ->
      ( { model
          | clock = Clock.update (ClockMsg.AdvanceHours 3) model.clock }
      , Cmd.none
      )

    ChangeDripRate ->
      ( { model
          | droplet = Droplet.update (DropletMsg.ChangeDripRate model.speedControl.perSecond) model.droplet }
      , Cmd.none
      )

    AnimationClockTick tick ->
      ( { model
          | droplet = Droplet.update (DropletMsg.AnimationClockTick tick) model.droplet
          , clock = Clock.update (ClockMsg.AnimationClockTick tick) model.clock
        }
      , Cmd.none
      )

