module Pile.Css.H exposing (..)

type FormStatus
  = AllGood
  | SomeBad
  | BeingSaved

type Urgency
  = Info 
  | Error

type Validity
  = Valid
  | Invalid

type alias FormValue t =
  { validity : Validity
  , value : t
  , commentary : List (Urgency, String)
  }

freshValue : t -> FormValue t
freshValue v =
  FormValue Valid v []
    
invalidate : String -> FormValue t -> FormValue t
invalidate msg formValue =
  FormValue Invalid formValue.value <| (Error, msg) :: formValue.commentary


