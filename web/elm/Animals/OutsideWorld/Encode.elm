module Animals.OutsideWorld.Encode exposing (..)

import Animals.Types.Animal exposing (..)
import Dict exposing (Dict)
import Date.Extra as Date
import Json.Encode as Encode
import Pile.DateHolder as DateHolder exposing (DateHolder)

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

animal : Animal -> Encode.Value
animal animal =
  let
    intId = Result.withDefault -1 (String.toInt animal.id)
    creationDateString = Date.toIsoString animal.creationDate
  in
    Encode.object [ ("id", Encode.int intId)
                  , ("version", Encode.int animal.version)
                  , ("name", Encode.string animal.name)
                  , ("species", Encode.string animal.species)
                  , ("tags", Encode.list (List.map Encode.string animal.tags))
                  , ("bool_properties", properties Encode.bool Dict.empty)
                  , ("int_properties", properties Encode.int Dict.empty)
                  , ("string_properties", properties Encode.string Dict.empty)
                  , ("creation_date", Encode.string creationDateString)
                  ]

-- Util

      
properties : (t -> Encode.Value) -> Dict String (t, String) -> Encode.Value
properties valueEncoder =
  let 
    encodeKV (k, (v, comment)) =
      (k, Encode.list [ valueEncoder v, Encode.string comment ])
  in
    Dict.toList >> List.map encodeKV >> Encode.object 
