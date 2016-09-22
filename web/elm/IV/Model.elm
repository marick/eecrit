module IV.Model exposing (..)

import IV.Droplet exposing (Droplet)

type alias Model =
    { droplet : Droplet
    , currentSpeed : Float
    , desiredNextSpeed : String
    }


