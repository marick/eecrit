module Animals.OutsideWorld.Json exposing (..)

import Animals.Animal.Types exposing (..)
import Animals.OutsideWorld.Declare exposing (..)
import Date
import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Encode as Encode

encodeAnimal animal =
  let
    inTransferFormat = putAnimalInTransferFormat animal

    encoded =
      Encode.object [ ("id", Encode.int inTransferFormat.id)
                    , ("version", Encode.int inTransferFormat.version)
                    , ("name", Encode.string inTransferFormat.name)
                    , ("species", Encode.string inTransferFormat.species)
                    , ("tags", Encode.list (List.map Encode.string inTransferFormat.tags))
                    , ("bool_properties", encodeProperties Encode.bool inTransferFormat.bool_properties)
                    , ("int_properties", encodeProperties Encode.int inTransferFormat.int_properties)
                    , ("string_properties", encodeProperties Encode.string inTransferFormat.string_properties)
                    ]
  in
    Encode.object [("data", encoded)]

decodeAnimal : Decode.Decoder Animal 
decodeAnimal =
  decodeToAnimalTransferFormat |> Decode.map translateToAnimal 
  
decodeAnimals : Decode.Decoder (List Animal)
decodeAnimals =
  Decode.at ["data"] (Decode.list decodeAnimal)
  
decodeSaveResult =
  let 
    intoTransferFormat =
      (Decode.map2 (,)
         (Decode.field "id" Decode.int)
         (Decode.field "version" Decode.int))

    fromTransferFormat (intId, version) =
      AnimalUpdated (toString intId) version
  in
    Decode.at ["data"] 
      (intoTransferFormat |> Decode.map fromTransferFormat)

--- Representation translation

type alias AnimalTransferFormat =
    { id : Int
    , version : Int
    , name : String
    , species : String
    , tags : List String
    , int_properties : Dict String ( Int, String )
    , bool_properties : Dict String ( Bool, String )
    , string_properties : Dict String ( String, String )
    }

decodeToAnimalTransferFormat : Decode.Decoder AnimalTransferFormat
decodeToAnimalTransferFormat =
    Decode.map8 AnimalTransferFormat
        (Decode.field "id" Decode.int)
        (Decode.field "version" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "species" Decode.string)
        (Decode.field "tags" (Decode.list Decode.string))
        -- It's just easier to have the Elixir side separate the union types
        
        (Decode.field "int_properties" (decodeProperties Decode.int))
        (Decode.field "bool_properties" (decodeProperties Decode.bool))
        (Decode.field "string_properties" (decodeProperties Decode.string))

putAnimalInTransferFormat : Animal -> AnimalTransferFormat
putAnimalInTransferFormat animal =
  let
    intId = Result.withDefault -1 (String.toInt animal.id)
  in
    { id = intId
    , version = animal.version
    , name = animal.name
    , species = animal.species
    , tags = animal.tags
    , bool_properties = Dict.empty
    , int_properties = Dict.empty
    , string_properties = Dict.empty
    }

translateToAnimal : AnimalTransferFormat -> Animal
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


--- Util      
      
decodeProperties : Decode.Decoder t -> Decode.Decoder (Dict String (t, String))
decodeProperties valueDecoder =
  Decode.dict (Decode.map2 (,)
                 (Decode.index 0 valueDecoder)
                 (Decode.index 1 Decode.string))

encodeProperties : (t -> Encode.Value) ->
                   Dict String (t, String) -> Encode.Value
encodeProperties valueEncoder =
  let 
    encodeKV (k, (v, comment)) =
      (k, Encode.list [ valueEncoder v, Encode.string comment ])
  in
    Dict.toList >> List.map encodeKV >> Encode.object 
