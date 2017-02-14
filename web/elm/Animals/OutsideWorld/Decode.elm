module Animals.OutsideWorld.Decode exposing (..)

import Animals.Types.Animal exposing (..)
import Animals.Types.Basic exposing (..)
import Animals.Types.AnimalHistory as AnimalHistory
import Animals.OutsideWorld.H exposing (..)
import Dict exposing (Dict)
import Date exposing (Date)
import Date.Extra as Date
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Decode

--- Aggregates

withinData : Decoder a -> Decoder a
withinData =
  Decode.at ["data"]

animals : Decoder (List Animal)
animals =
  Decode.list animal
  
history : Decoder (List AnimalHistory.Entry)
history =
  Decode.list historyEntry

    
saveResponse : Decoder AnimalSaveResults
saveResponse =
  let 
    to_transferFormat =
      (Decode.field "id" Decode.int)

    from_transferFormat intId =
      AnimalUpdated (toString intId)
  in
    (to_transferFormat |> Decode.map from_transferFormat)


creationResponse : Decoder AnimalCreationResults
creationResponse =
  let 
    to_transferFormat =
      (Decode.map2 (,)
         (Decode.field "originalId" Decode.string)
         (Decode.field "serverId" Decode.int))

    from_transferFormat (originalId, serverId) =
      AnimalCreated originalId (toString serverId)
  in
    (to_transferFormat |> Decode.map from_transferFormat)


--- History entries

historyEntry : Decoder AnimalHistory.Entry
historyEntry =
  json_to_HistoryEntryInputFormat |> Decode.map historyEntryInputFormat_to_Entry
    
  
type alias HistoryEntryInputFormat =
    { name_change : Maybe String
    , new_tags : List String
    , deleted_tags : List String
    , effective_date : String
    , audit_date : String
    , audit_author : String
    }

json_to_HistoryEntryInputFormat : Decoder HistoryEntryInputFormat
json_to_HistoryEntryInputFormat =
  Decode.decode HistoryEntryInputFormat
    |> Decode.required "name_change" (Decode.nullable Decode.string)
    |> Decode.required "new_tags" (Decode.list Decode.string)
    |> Decode.required "deleted_tags" (Decode.list Decode.string)
    |> Decode.required "effective_date" (Decode.string)
    |> Decode.required "audit_date" Decode.string
    |> Decode.required "audit_author" Decode.string
          
historyEntryInputFormat_to_Entry : HistoryEntryInputFormat -> AnimalHistory.Entry
historyEntryInputFormat_to_Entry incoming = 
  { nameChange = incoming.name_change
  , newTags = incoming.new_tags
  , deletedTags = incoming.deleted_tags
  , effectiveDate = fromIsoString incoming.effective_date
  , audit = { author = incoming.audit_author
            , date = fromIsoString incoming.audit_date
            }
  }

--- Animal 

animal : Decoder Animal 
animal =
  json_to_AnimalInputFormat |> Decode.map animalInputFormat_to_Animal


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

json_to_AnimalInputFormat : Decoder AnimalInputFormat
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

--- Util      

fromIsoString : String -> Date
fromIsoString s = 
  case Date.fromIsoString s of
    Just date -> date
    Nothing -> Date.fromCalendarDate 2000 Date.Jan 1 -- impossible

      
decodeProperties : Decoder t -> Decoder (Dict String (t, String))
decodeProperties valueDecoder =
  Decode.dict (Decode.map2 (,)
                 (Decode.index 0 valueDecoder)
                 (Decode.index 1 Decode.string))
