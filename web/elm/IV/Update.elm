module IV.Update exposing (update)

import IV.Msg exposing (Msg(..))
import IV.Model exposing (Model)
import String
import IV.Droplet.Update as Droplet
import IV.SpeedControl.Update as SpeedControl
import IV.Droplet.Msg as DropletMsg
import IV.SpeedControl.Msg as SpeedMsg

floatSpeed model =
  if String.isEmpty model.speedControl.desiredNextSpeed then
    model
  else
    case String.toInt model.speedControl.desiredNextSpeed of
        Ok n ->
          {model | currentSpeed = toFloat n}
        Err _ ->
          model
  
startAnimation model = 
  { model | droplet = Droplet.update (DropletMsg.ChangeDripRate model.currentSpeed) model.droplet }

    

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    PressedGoButton -> 
      ( model |> floatSpeed |> startAnimation
      , Cmd.none
      )

    ChangedTextField nextString ->
      ( { model
          | speedControl = SpeedControl.update (SpeedMsg.ChangedTextField nextString) model.speedControl
        }
      , Cmd.none)
        
    Animate time ->
      ( { model
          | droplet = Droplet.update (DropletMsg.Animate time) model.droplet 
        }
      , Cmd.none
      )

