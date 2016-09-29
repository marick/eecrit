module IV.Scenario.Model exposing (..)

import IV.Types exposing (..)

-- It's convenient to store both of these values
type alias DripDesire =
  { string : String
  , perSecond : DropsPerSecond
  }

dripDesire : DropsPerSecond -> DripDesire
dripDesire ((DropsPerSecond float) as perSecond) = 
  { string = toString float
  , perSecond = perSecond
  }

type alias Model =
  { drip : DripDesire
  , animalDescription : String
  , weightInPounds : Int
  , simulationInHours : Int
  }

startingState : DropsPerSecond -> Model
startingState dropsPerSecond = 
  { drip = dripDesire dropsPerSecond
  , animalDescription = "3d lactation purebred Holstein"
  , weightInPounds = 1560
  , simulationInHours = 1
  }
