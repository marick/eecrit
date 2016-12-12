module Animals.Animal.Validation exposing (..)

import String
import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)


type alias ValidationContext =
  { allAnimalNames : List String
  }

type alias ValidationResult value =
  Result (value, String) value

type alias ValidatedForm =
  { name : ValidationResult String
  , maySave : Bool
  }

assumeAllValid : Form -> ValidatedForm
assumeAllValid form =
  { name = Ok form.name
  , maySave = True
  }

validateForm : ValidationContext -> Form -> ValidatedForm
validateForm context form =
  form
    |> assumeAllValid
    |> check (mustHaveName context form) validationForm_name

mustHaveName context form =
  calculateResult "The animal has to have a name!"
    (form_name.get form)
    (not << String.isEmpty)


-- Util
      
check validatedResult lens buildingForm =
  case validatedResult of
    Ok _ ->
      buildingForm
    Err _ ->
      buildingForm |> lens.set validatedResult |> validationForm_maySave.set False
       
calculateResult : String -> value -> (value -> Bool) -> ValidationResult value 
calculateResult requirement value pred =
  if pred value then
    Ok value
  else
    Err (value, requirement)

      
