module Animals.Animal.Validation exposing (..)

import String
import Animals.Animal.Model exposing (..)


validate : String -> value -> (value -> Bool) -> Result (value, String) value 
validate requirement value pred =
  if pred value then
    Ok value
  else
    Err (value, requirement)

validatedName form =
  validate "The animal has to have a name!"
    (form_name.get form)
    (not << String.isEmpty)

-- This is way too fragile
isSafeToSave form =
  case validatedName form of
    Ok x -> True
    Err x -> False
