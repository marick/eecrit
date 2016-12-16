module Animals.OutsideWorld exposing
  ( fetchAnimals
  , askTodaysDate
  )

import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)
import Date
import Dict exposing (Dict)
import Task
import Json.Decode as Decode
import Http

askTodaysDate =
  Task.perform (SetToday << Just) Date.now

---
    
fetchAnimals =
  let
    url = "/api/v2animals"
    request = Http.get url decodeAnimals
  in
    Cmd.batch 
      [ --- Task.perform SetAnimals (Task.succeed [athena, ross, xena, jake])
       Http.send SetAnimals (Debug.log "req" request)
      ]

type alias IncomingAnimal =
    { id : Int
    , name : String
    , species : String
    , tags : List String
    , int_properties : Dict String ( Int, String )
    , bool_properties : Dict String ( Bool, String )
    }

decodeAnimals : Decode.Decoder (List Animal)
decodeAnimals =
  Decode.at ["data"] (Decode.list animalDecoder)
  
animalDecoder : Decode.Decoder Animal 
animalDecoder =
  Decode.map translateToAnimal toIncomingAnimal
  
toIncomingAnimal : Decode.Decoder IncomingAnimal
toIncomingAnimal =
    Decode.map6 IncomingAnimal
        (Decode.field "id" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "species" Decode.string)
        (Decode.field "tags" (Decode.list Decode.string))
        -- It's just easier to have the Elixir side separate the union types
        (Decode.field "int_properties"
           (Decode.dict (Decode.map2 (,)
                           (Decode.index 0 Decode.int)
                           (Decode.index 1 Decode.string))))
        (Decode.field "bool_properties"
           (Decode.dict (Decode.map2 (,)
                           (Decode.index 0 Decode.bool)
                           (Decode.index 1 Decode.string))))


translateToAnimal : IncomingAnimal -> Animal
translateToAnimal incoming =
    let
        ints =
            Dict.map (\_ tuple -> (uncurry AsInt) tuple) incoming.int_properties

        bools =
            Dict.map (\_ tuple -> (uncurry AsBool) tuple) incoming.bool_properties

        properties =
            ints |> Dict.union bools
    in
        { id = toString incoming.id
        , wasEverSaved = True
        , name = incoming.name
        , species = incoming.species
        , tags = incoming.tags
        , properties = properties
        }




      
      
athena =
  { id = "predefined1"
  , wasEverSaved = True
  , name = "Athena"
  , species = "bovine"
  , tags = [ "cow" ]
  , properties = Dict.fromList [ ("Available", AsBool True "")
                               , ("Primary billing", AsString "Marick" "")
                               ]
  }

jake =
  { id = "predefined2"
  , wasEverSaved = True
  , name = "Jake"
  , species = "equine"
  , tags = [ "gelding" ]
  , properties = Dict.fromList [ ("Available", AsBool True "") ] 
  }

ross =
  { id = "predefined3"
  , wasEverSaved = True
  , name = "ross"
  , species = "equine"
  , tags = [ "stallion", "aggressive"]
  , properties = Dict.fromList [ ("Available", AsBool True "")
                               , ("Primary billing", AsString "Marick" "")
                               ] 
  }

xena =
  { id = "predefined4"
  , wasEverSaved = True
  , name = "Xena"
  , species = "equine"
  , tags = [ "mare", "skittish" ]
  , properties = Dict.fromList [ ("Available", AsBool False "off for the summer")
                               , ("Primary billing", AsString "Marick" "")
                               ]
                                    
  }
