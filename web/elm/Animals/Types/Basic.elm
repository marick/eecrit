module Animals.Types.Basic exposing (..)

import Date exposing (Date)
import Dict exposing (Dict)

type alias Id = String

type DictValue
  = AsInt Int String
  | AsString String String
  | AsBool Bool String
  -- These will probably be added eventually
--  | AsFloat Float String
--  | AsDate Date String

type alias Properties = Dict String DictValue
  
