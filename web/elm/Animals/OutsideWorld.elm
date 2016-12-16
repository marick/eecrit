module Animals.OutsideWorld exposing
  ( fetchAnimals
  , askTodaysDate
  )

import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)
import Date
import Dict
import Task

askTodaysDate =
  Task.perform (SetToday << Just) Date.now

fetchAnimals =
  Task.perform SetAnimals
    (Task.succeed [athena, ross, xena, jake])

athena =
  { id = "predefined1"
  , wasEverSaved = True
  , name = "Athena"
  , species = "bovine"
  , tags = [ "cow" ]
  , properties = Dict.fromList [ ("Available", AsBool True Nothing)
                               , ("Primary billing", AsString "Marick")
                               ]
  }

jake =
  { id = "predefined2"
  , wasEverSaved = True
  , name = "Jake"
  , species = "equine"
  , tags = [ "gelding" ]
  , properties = Dict.fromList [ ("Available", AsBool True Nothing) ] 
  }

ross =
  { id = "predefined3"
  , wasEverSaved = True
  , name = "ross"
  , species = "equine"
  , tags = [ "stallion", "aggressive"]
  , properties = Dict.fromList [ ("Available", AsBool True Nothing)
                               , ("Primary billing", AsString "Forman")
                               ] 
  }

xena =
  { id = "predefined4"
  , wasEverSaved = True
  , name = "Xena"
  , species = "equine"
  , tags = [ "mare", "skittish" ]
  , properties = Dict.fromList [ ("Available", AsBool False (Just "off for the summer"))
                               , ("Primary billing", AsString "Forman")
                               ]
                                    
  }
