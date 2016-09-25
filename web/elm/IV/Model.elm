module IV.Model exposing (..)

import IV.Droplet.Model as Droplet
import IV.Clock.Model as Clock
import IV.SpeedControl.Model as SpeedControl

type alias Model =
    { droplet : Droplet.Model
    , speedControl : SpeedControl.Model
    , clock : Clock.Model
    }
