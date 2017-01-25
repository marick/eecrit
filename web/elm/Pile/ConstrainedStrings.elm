module Pile.ConstrainedStrings exposing (..)

import Pile.UpdatingLens exposing (UpdatingLens)
import String
import String.Extra as String

-- Generic validation

isValid : (String -> Result error value) -> String -> Bool
isValid validator string = 
  case validator string of
    Ok _ -> True
    Err _ -> False

convertWithDefault: (String -> Result error val) -> val -> String -> val
convertWithDefault transformer default string =
  case transformer string of
    Ok valid -> valid
    Err _ -> default

-- This is to be used in the case where you *know* the string will convert
-- successfully, so the default should never be used (but should nevertheless
-- be a safe value.
certainlyValid: (String -> Result error val) -> String -> val -> val
certainlyValid transformer string impossibleValue =
  convertWithDefault transformer impossibleValue string 
             
hasPotential : (String -> Result error value) -> String -> Bool
hasPotential validator string =
  case String.isBlank string of 
    True -> True
    False -> isValid validator string

updateIfPotential : (String -> Result error value) -> String 
                    -> UpdatingLens model String
                    -> (model -> model)
updateIfPotential validator string lens =
  case hasPotential validator string of
    True -> lens.set string
    False -> identity

-- Classification (details depend on parsed string type)

type StringClassification parsedStringType
  = Blank
  | DoesNotParse
  | ParsedButWrong parsedStringType
  | Parsed parsedStringType
                    


-- String is intended to be an int

isValidIntString : String -> Bool
isValidIntString = isValid String.toInt

isPotentialIntString : String -> Bool
isPotentialIntString = hasPotential String.toInt

updateIfPotentialIntString : String -> UpdatingLens model String -> model -> model
updateIfPotentialIntString = updateIfPotential String.toInt

convertWithDefaultInt : Int -> String -> Int
convertWithDefaultInt = convertWithDefault String.toInt                             
                             
certainlyValidInt : String -> Int -> Int
certainlyValidInt = certainlyValid String.toInt                             

-- Note: this treats "    3" as a valid integer, which `String.toInt` does not.
classify_strictlyPositive : String -> StringClassification Int
classify_strictlyPositive string =
  case (String.isBlank string, String.toInt <| String.trim string) of
    (True, _) -> Blank
    (_, Err _) -> DoesNotParse
    (_, Ok n) -> if n <= 0 then
                  ParsedButWrong n
                 else
                   Parsed n
