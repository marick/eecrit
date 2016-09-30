module IV.Pile.ManagedStrings exposing (..)

import String


isValidFloatString : String -> Bool
-- TODO: Why can't I write this without `if` and `case`?
isValidFloatString string =
  if String.isEmpty string then
    True
  else
    case String.toFloat string of
      Ok float ->
        True
      Err _ ->
        False


floatString : String -> Float
floatString string = 
  if String.isEmpty string then
    0.0
  else
    case String.toFloat string of
      Ok float ->
        float
      Err _ ->
        1000000000.0 -- Make it noticeable?




isValidIntString : String -> Bool
-- TODO: Why can't I write this without `if` and `case`?
isValidIntString string =
  if String.isEmpty string then
    True
  else
    case String.toInt string of
      Ok int ->
        True
      Err _ ->
        False


intString : String -> Int
intString string = 
  if String.isEmpty string then
    0
  else
    case String.toInt string of
      Ok int ->
        int
      Err _ ->
        1000000000 -- Make it noticeable?

          
