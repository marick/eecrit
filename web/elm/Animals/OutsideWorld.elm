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
  Task.perform (always (SetToday Nothing)) (SetToday << Just) Date.now

fetchAnimals =
  Task.perform (always (SetAnimals [])) SetAnimals
    (Task.succeed [athena, ross, xena, jake])

athena =
  { id = "1"
  , name = "Athena"
  , species = "bovine"
  , tags = [ "cow" ]
  , properties = Dict.fromList [ ("Available", AsBool True Nothing)
                               , ("Primary billing", AsString "Marick")
                               ]
  }

jake =
  { id = "2"
  , name = "Jake"
  , species = "equine"
  , tags = [ "gelding" ]
  , properties = Dict.fromList [ ("Available", AsBool True Nothing) ] 
  }

ross =
  { id = "3"
  , name = "ross"
  , species = "equine"
  , tags = [ "stallion", "aggressive"]
  , properties = Dict.fromList [ ("Available", AsBool True Nothing)
                               , ("Primary billing", AsString "Forman")
                               ] 
  }

xena =
  { id = "4"
  , name = "Xena"
  , species = "equine"
  , tags = [ "mare", "skittish" ]
  , properties = Dict.fromList [ ("Available", AsBool False (Just "off for the summer"))
                               , ("Primary billing", AsString "Forman")
                               ]
                                    
  }
