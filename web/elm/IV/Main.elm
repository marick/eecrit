module IV.Main exposing (..)
import Html.App
import Animation
import IV.Droplet.Model as Droplet
import IV.SpeedControl.Model as SpeedControl
import IV.Msg exposing (Msg(..))
import IV.Model exposing (Model)
import IV.Update exposing (update)
import IV.View exposing (view)

init : ( Model, Cmd Msg )
init =
    ( { droplet = Droplet.startingState 800.0 
      , speedControl = SpeedControl.startingState "800" 800.0
      }
    , Cmd.none
    )

subscriptions model =
  Animation.subscription
    AnimationClockTick
    [ Droplet.animation model.droplet
    ]

main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
