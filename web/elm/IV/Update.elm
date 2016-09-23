module IV.Update exposing (update)

import IV.Msg exposing (Msg(..))
import IV.Model exposing (Model)
import String
import IV.Droplet.Update as Droplet
import IV.Droplet.Msg as DropletMsg

floatSpeed model =
  if String.isEmpty model.desiredNextSpeed then
    model
  else
    case String.toInt model.desiredNextSpeed of
        Ok n ->
          {model | currentSpeed = toFloat n}
        Err _ ->
          model
  
updateNextSpeed model nextString =
  if String.isEmpty nextString then
    {model | desiredNextSpeed = nextString}
  else
    case String.toInt nextString of
        Ok _ ->
          {model | desiredNextSpeed = nextString}
        Err _ ->
          model

startAnimation model = 
  { model | droplet = Droplet.update (DropletMsg.ChangeDripRate model.currentSpeed) model.droplet }

    

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Go -> 
      ( model |> floatSpeed |> startAnimation
      , Cmd.none
      )
      
    UpdateSpeed nextString ->
      ( updateNextSpeed model nextString, Cmd.none)
        
    Animate time ->
      ( { model
          | droplet = Droplet.update (DropletMsg.Animate time) model.droplet 
        }
      , Cmd.none
      )

