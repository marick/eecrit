module Animals.OutsideWorld.Encode exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal exposing (..)
import Dict exposing (Dict)
import Date.Extra as Date
import Json.Encode as Encode
import Pile.DateHolder as DateHolder exposing (DateHolder)

animal : Animal -> Encode.Value
animal animal =
  let
    intId = Result.withDefault -1 (String.toInt animal.id)
    creationDateString = Date.toIsoString animal.creationDate
    outProps = separate animal.properties
  in
    Encode.object [ ("id", Encode.int intId)
                  , ("version", Encode.int animal.version)
                  , ("name", Encode.string animal.name)
                  , ("species", Encode.string animal.species)
                  , ("tags", Encode.list (List.map Encode.string animal.tags))
                  , ("bool_properties", properties Encode.bool outProps.bools)
                  , ("int_properties", properties Encode.int outProps.ints)
                  , ("string_properties", properties Encode.string outProps.strings)
                  , ("creation_date", Encode.string creationDateString)
                  ]

addingMetadata : DateHolder -> Encode.Value -> Encode.Value
addingMetadata holder v =
  let
    effective_date =
      holder |> DateHolder.convertToDate |> Date.toIsoString |> Encode.string
    audit_date =
      holder |> DateHolder.todayDate |> Date.toIsoString |> Encode.string
        
    metadata =
      Encode.object
        [ ("effective_date", effective_date)
        , ("audit_date", audit_date)
        ]
  in
    Encode.object
      [ ("data", v)
      , ("metadata", metadata)
      ]    

-- Util

      
properties : (t -> Encode.Value) -> Dict String (t, String) -> Encode.Value
properties valueEncoder =
  let 
    encodeKV (k, (v, comment)) =
      (k, Encode.list [ valueEncoder v, Encode.string comment ])
  in
    Dict.toList >> List.map encodeKV >> Encode.object 



type alias SeparatedProperties =
  { ints : Dict String (Int, String)
  , strings: Dict String (String, String)
  , bools: Dict String (Bool, String)
  }
      
separate : Properties -> SeparatedProperties
separate properties = 
  let
    empty = { ints = Dict.empty, strings = Dict.empty, bools = Dict.empty }
    step key sumValue building =
      case sumValue of
        AsInt v s ->
          { building | ints = Dict.insert key (v, s) building.ints}
        AsString  v s -> 
          { building | strings = Dict.insert key (v, s) building.strings}
        AsBool v s -> 
          { building | bools = Dict.insert key (v, s) building.bools}
  in
    Dict.foldl step empty properties
      
