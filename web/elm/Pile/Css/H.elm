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

silentlyInvalid : t -> FormValue t
silentlyInvalid v = 
  FormValue Invalid v []
    
invalidate : String -> FormValue t -> FormValue t
invalidate text formValue =
  FormValue Invalid formValue.value <| (Error, text) :: formValue.commentary


