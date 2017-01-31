module Animals.OutsideWorld.Json exposing (..)

import Animals.Types.Animal exposing (..)
import Animals.Types.Basic exposing (..)
import Animals.OutsideWorld.H exposing (..)
import Dict exposing (Dict)
import Date exposing (Date)
import Date.Extra as Date
import Json.Decode as Decode
import Json.Encode as Encode
import Json.Decode.Pipeline as Decode

withinData : Decode.Decoder a -> Decode.Decoder a
withinData =
  Decode.at ["data"]

asData : Encode.Value -> Encode.Value
asData v = 
  Encode.object [("data", v)]    

decodeAnimals : Decode.Decoder (List Animal)
decodeAnimals =
  Decode.list decodeAnimal
  
decodeAnimal : Decode.Decoder Animal 
decodeAnimal =
  json_to_AnimalTransferFormat |> Decode.map animalTransferFormat_to_Animal 
  
encodeAnimal : Animal -> Encode.Value
encodeAnimal =
  animal_to_animalTransferFormat >> animalTransferFormat_to_json

decodeSaveResult : Decode.Decoder AnimalSaveResults
decodeSaveResult =
  let 
    to_transferFormat =
      (Decode.field "id" Decode.int)

    from_transferFormat intId =
      AnimalUpdated (toString intId)
  in
    (to_transferFormat |> Decode.map from_transferFormat)


decodeCreationResult : Decode.Decoder AnimalCreationResults
decodeCreationResult =
  let 
    to_transferFormat =
      (Decode.map2 (,)
         (Decode.field "originalId" Decode.string)
         (Decode.field "serverId" Decode.int))

    from_transferFormat (originalId, serverId) =
      AnimalCreated originalId (toString serverId)
  in
    (to_transferFormat |> Decode.map from_transferFormat)




--- Animal support


type alias AnimalTransferFormat =
    { id : Int
    , version : Int
    , name : String
    , species : String
    , tags : List String
    , int_properties : Dict String ( Int, String )
    , bool_properties : Dict String ( Bool, String )
    , string_properties : Dict String ( String, String )
    , creation_date : String
    }

json_to_AnimalTransferFormat : Decode.Decoder AnimalTransferFormat
json_to_AnimalTransferFormat =
  Decode.decode AnimalTransferFormat
    |> Decode.required "id" Decode.int
    |> Decode.required "version" Decode.int
    |> Decode.required "name" Decode.string
    |> Decode.required "species" Decode.string
    |> Decode.required "tags" (Decode.list Decode.string)
    -- It's just easier to have the Elixir side separate the union types
      
    |> Decode.required "int_properties" (decodeProperties Decode.int)
    |> Decode.required "bool_properties" (decodeProperties Decode.bool)
    |> Decode.required "string_properties" (decodeProperties Decode.string)
    |> Decode.required "creation_date" Decode.string

animalTransferFormat_to_json : AnimalTransferFormat -> Encode.Value
animalTransferFormat_to_json xfer = 
  Encode.object [ ("id", Encode.int xfer.id)
                    , ("version", Encode.int xfer.version)
                    , ("name", Encode.string xfer.name)
                    , ("species", Encode.string xfer.species)
                    , ("tags", Encode.list (List.map Encode.string xfer.tags))
                    , ("bool_properties", encodeProperties Encode.bool xfer.bool_properties)
                    , ("int_properties", encodeProperties Encode.int xfer.int_properties)
                    , ("string_properties", encodeProperties Encode.string xfer.string_properties)
                    , ("creation_date", Encode.string (xfer.creation_date))
                    ]

animal_to_animalTransferFormat : Animal -> AnimalTransferFormat
animal_to_animalTransferFormat animal =
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
    , creation_date = Date.toIsoString animal.creationDate
    }
          
animalTransferFormat_to_Animal : AnimalTransferFormat -> Animal
animalTransferFormat_to_Animal incoming =
    let
        properties = combine [ints, bools, strings] 
                     
        combine dicts =
          List.foldl (\one many -> Dict.union many one) Dict.empty dicts

        ints = dictify AsInt incoming.int_properties
        bools = dictify AsBool incoming.bool_properties
        strings = dictify AsString incoming.string_properties

        dictify unionF data = 
          Dict.map (\_ tuple -> (uncurry unionF) tuple) data
        _
          = Debug.log "foo" incoming.creation_date
    in
        { id = toString incoming.id
        , displayFormat = Compact
        , version = incoming.version
        , name = incoming.name
        , species = incoming.species
        , tags = incoming.tags
        , properties = properties
        , creationDate = fromIsoString incoming.creation_date
        }


fromIsoString s = 
  case Date.fromIsoString s of
    Just date -> date
    Nothing -> Date.fromCalendarDate 2000 Date.Jan 1 -- impossible

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



      
