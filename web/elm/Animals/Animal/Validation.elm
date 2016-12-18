module Animals.Animal.Validation exposing (..)

import Set exposing (Set)
import String
import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)


specializeValidationContext animal =
  validationContext_allAnimalNames.update (Set.remove animal.name)
  
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
    |> check (uniqueName context form) validationForm_name

validateFormForAnimal context animal form = 
  validateForm (specializeValidationContext animal context) form 

       
mustHaveName context form =
  calculateResult "The animal has to have a name!"
    (form_name.get form)
    (not << String.isEmpty)

uniqueName context form =
  calculateResult "There is already an animal with that name!"
    (form_name.get form)
    (not << (flip Set.member) context.allAnimalNames)

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

      
