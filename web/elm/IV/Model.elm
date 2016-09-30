module IV.Model exposing (..)

import IV.Droplet.Main as Droplet
import IV.Clock.Model as Clock
import IV.Scenario.Main as Scenario
import IV.BagLevel.Main as BagLevel

type alias Model =
    { droplet : Droplet.Model
    , scenario : Scenario.Model
    , clock : Clock.Model
    , bagLevel : BagLevel.Model
    }
