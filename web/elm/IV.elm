module IV exposing (..)
import Html.App
import Animation
import IV.Droplet.Main as Droplet
import IV.Scenario.Main as Scenario
import IV.Clock.Model as Clock
import IV.BagLevel.Main as BagLevel
import IV.Msg exposing (Msg(..))
import IV.Model exposing (Model)
import IV.Update exposing (update)
import IV.View exposing (view)
import IV.Types exposing (..)

init : ( Model, Cmd Msg )
init =
  ( { droplet = Droplet.startingState
    , scenario = Scenario.startingState
    , clock = Clock.startingState
    , bagLevel = BagLevel.startingState
    }
  , Cmd.none
  )

subscriptions model =
  Animation.subscription
    AnimationClockTick
    (Droplet.animations model.droplet ++ Clock.animations model.clock)

main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
