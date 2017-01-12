module Animals.Types.Basic exposing (..)

import Date exposing (Date)
import Dict exposing (Dict)

type alias Id = String

type DictValue
  = AsInt Int String
  | AsFloat Float String
  | AsString String String
  | AsDate Date String
  | AsBool Bool String

type alias Properties = Dict String DictValue
  
