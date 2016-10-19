module IV.Scenario.Model exposing (..)

type alias Model =
  { tag : String
  , dripText : String
  , animalDescription : String
  , weightInPounds : Int
  , simulationHoursText : String
  , simulationMinutesText : String
  , bagCapacityInLiters : Float
  , bagContentsInLiters : Float
  , bagType : String
  , dropsPerMil : Float
  }

