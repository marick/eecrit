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
import Pile.DateHolder as DateHolder exposing (DateHolder)

withinData : Decode.Decoder a -> Decode.Decoder a
withinData =
  Decode.at ["data"]

animalInstructions : DateHolder -> Encode.Value -> Encode.Value
animalInstructions holder v = 
  Encode.object [("data", v)]    

decodeAnimals : Decode.Decoder (List Animal)
decodeAnimals =
  Decode.list decodeAnimal
  
decodeAnimal : Decode.Decoder Animal 
decodeAnimal =
  json_to_AnimalInputFormat |> Decode.map animalInputFormat_to_Animal 
  
encodeOutgoingAnimal : Date -> Animal -> Encode.Value
encodeOutgoingAnimal effectiveDate animal =
  let
    intId = Result.withDefault -1 (String.toInt animal.id)
    creationDateString = Date.toIsoString animal.creationDate
    effectiveDateString = Date.toIsoString effectiveDate
  in
    Encode.object [ ("id", Encode.int intId)
                  , ("version", Encode.int animal.version)
                  , ("name", Encode.string animal.name)
                  , ("species", Encode.string animal.species)
                  , ("tags", Encode.list (List.map Encode.string animal.tags))
                  , ("bool_properties", encodeProperties Encode.bool Dict.empty)
                  , ("int_properties", encodeProperties Encode.int Dict.empty)
                  , ("string_properties", encodeProperties Encode.string Dict.empty)
                  , ("creation_date", Encode.string creationDateString)
                  , ("effective_date", Encode.string effectiveDateString)
                  ]
      


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


type alias AnimalInputFormat =
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

json_to_AnimalInputFormat : Decode.Decoder AnimalInputFormat
json_to_AnimalInputFormat =
  Decode.decode AnimalInputFormat
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
          
animalInputFormat_to_Animal : AnimalInputFormat -> Animal
animalInputFormat_to_Animal incoming =
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



      
