module IV.Model exposing (..)

import IV.Droplet as Droplet

type alias Model =
    { droplet : Droplet.Model
    , currentSpeed : Float
    , desiredNextSpeed : String
    }


