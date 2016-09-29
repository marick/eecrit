module IV.Model exposing (..)

import IV.Droplet.Main as Droplet
import IV.Clock.Model as Clock
import IV.Scenario.Model as Scenario

type alias Model =
    { droplet : Droplet.Model
    , speedControl : Scenario.Model
    , clock : Clock.Model
    }
