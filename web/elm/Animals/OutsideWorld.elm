module Animals.OutsideWorld exposing (fetchAnimals)

import Animals.Types exposing (..)
import Dict

fetchAnimals = [athena, ross, xena, jake]

athena =
  { id = "1"
  , name = "Athena"
  , species = "bovine"
  , tags = [ "cow" ]
  , properties = Dict.fromList [ ("Available", AsBool True Nothing)
                               , ("Primary billing", AsString "Marick")
                               ]
  , displayState = Compact
  , editableCopy = Nothing
  }

jake =
  { id = "2"
  , name = "Jake"
  , species = "equine"
  , tags = [ "gelding" ]
  , properties = Dict.fromList [ ("Available", AsBool True Nothing) ] 
  , displayState = Compact
  , editableCopy = Nothing
  }

ross =
  { id = "3"
  , name = "ross"
  , species = "equine"
  , tags = [ "stallion", "aggressive"]
  , properties = Dict.fromList [ ("Available", AsBool True Nothing)
                               , ("Primary billing", AsString "Forman")
                               ] 
  , displayState = Compact
  , editableCopy = Nothing
  }

xena =
  { id = "4"
  , name = "Xena"
  , species = "equine"
  , tags = [ "mare", "skittish" ]
  , properties = Dict.fromList [ ("Available", AsBool False (Just "off for the summer"))
                               , ("Primary billing", AsString "Forman")
                               ]
                                    
  , displayState = Compact
  , editableCopy = Nothing
  }
