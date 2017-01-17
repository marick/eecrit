module Pile.ConstrainedStrings exposing (..)

import Pile.UpdatingLens exposing (UpdatingLens)
import String

-- Generic validation

isValid : (String -> Result error value) -> String -> Bool
isValid validator string = 
  case validator string of
    Ok _ -> True
    Err _ -> False

certainlyValid: (String -> Result error val) -> String -> val -> val
certainlyValid transformer string impossibleValue =
  case transformer string of
    Ok valid -> valid
    Err _ -> impossibleValue
             
hasPotential : (String -> Result error value) -> String -> Bool
hasPotential validator string =
  case String.isEmpty string of 
    True -> True
    False -> isValid validator string

updateIfPotential : (String -> Result error value) -> String 
                    -> UpdatingLens model String
                    -> (model -> model)
updateIfPotential validator string lens =
  case hasPotential validator string of
    True -> lens.set string
    False -> identity


-- String is intended to be an int

isValidIntString : String -> Bool
isValidIntString = isValid String.toInt

isPotentialIntString : String -> Bool
isPotentialIntString = hasPotential String.toInt

updateIfPotentialIntString : String -> UpdatingLens model String -> model -> model
updateIfPotentialIntString = updateIfPotential String.toInt

certainlyValidInt : String -> Int -> Int
certainlyValidInt = certainlyValid String.toInt                             
                             
