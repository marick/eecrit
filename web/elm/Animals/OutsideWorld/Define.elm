module Animals.OutsideWorld.Define exposing
  ( fetchAnimals
  , askTodaysDate
  , saveAnimal
  )
import Animals.OutsideWorld.Declare exposing (..)
import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)
import Date
import Dict exposing (Dict)
import Task
import Json.Decode as Decode
import Json.Encode as Encode
import Http

askTodaysDate =
  Task.perform (SetToday << Just) Date.now

-- Animal creation

-- persistNewAnimal animal =
--   Task.perform Ok (Task.succeed { temporaryId = animal.id, newId = "newid" })

-- saveAnimal animal = 
--   Task.perform NoticeAnimalSaveResults (Task.succeed (Ok (AnimalUpdated animal.id 83))

---

saveAnimal animal =
  let
    url = "/api/v2animals"
    body = Http.jsonBody <| encodeAnimal animal
    request = Http.post url body decodeSaveResult
  in
    Http.send NoticeAnimalSaveResults request

encodeAnimal animal =
  Encode.object [("id", Encode.string animal.id)]

decodeSaveResult =
  Decode.at ["data"]
    (Decode.map2 AnimalUpdated
      (Decode.field "id" Decode.string)
      (Decode.field "version" Decode.int))

---
    
fetchAnimals =
  let
    url = "/api/v2animals"
    request = Http.get url decodeAnimals
  in
    Http.send SetAnimals request

decodeAnimals : Decode.Decoder (List Animal)
decodeAnimals =
  Decode.at ["data"] (Decode.list decodeOneAnimal)
  
decodeOneAnimal : Decode.Decoder Animal 
decodeOneAnimal =
  toIncomingAnimal |> Decode.map translateToAnimal 
  
toIncomingAnimal : Decode.Decoder IncomingAnimal
toIncomingAnimal =
    Decode.map8 IncomingAnimal
        (Decode.field "id" Decode.int)
        (Decode.field "version" Decode.int)
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
        (Decode.field "string_properties"
           (Decode.dict (Decode.map2 (,)
                           (Decode.index 0 Decode.string)
                           (Decode.index 1 Decode.string))))


translateToAnimal : IncomingAnimal -> Animal
translateToAnimal incoming =
    let
        properties = combine [ints, bools, strings] 
                     
        combine dicts =
          List.foldl (\one many -> Dict.union many one) Dict.empty dicts

        ints = dictify AsInt incoming.int_properties
        bools = dictify AsBool incoming.bool_properties
        strings = dictify AsString incoming.string_properties

        dictify unionF data = 
          Dict.map (\_ tuple -> (uncurry unionF) tuple) data
    in
        { id = toString incoming.id
        , version = incoming.version
        , wasEverSaved = True
        , name = incoming.name
        , species = incoming.species
        , tags = incoming.tags
        , properties = properties
        }

