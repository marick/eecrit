module IV.Main exposing (..)
import Html.App
import Animation
import IV.Droplet.Model as Droplet
import IV.Msg exposing (Msg(..))
import IV.Model exposing (Model)
import IV.Update exposing (update)
import IV.View exposing (view)

init : ( Model, Cmd Msg )
init =
    ( { droplet = Droplet.startingState
      , currentSpeed = 800.0
      , desiredNextSpeed = "800"
      }
    , Cmd.none
    )

subscriptions model =
--   Droplet.subscriptions model.droplet
--   Droplet.subscription Animate model.droplet
  Animation.subscription Animate
    [model.droplet.style]

main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

