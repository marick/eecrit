module Animals.Animal.Validation exposing (..)

import Dict exposing (Dict)
import Set exposing (Set)
import String
import Pile.Bulma exposing (FormValue, Urgency(..), Validity(..))

import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Aggregates as Aggregate
import Animals.Animal.Form as Form

context : Aggregate.VisibleAggregate -> Animal -> ValidationContext 
context animals changingAnimal  =
  { disallowedNames = Aggregate.animalNames animals |> Set.remove changingAnimal.name
  }

validate : Form -> ValidationContext -> Form
validate form context =
  Form.assumeValid form 
    |> validateName context

--  Validators
  
validateName : ValidationContext -> Form -> Form
validateName context form =
  form 
    |> validator "The animal has to have a name!" form_name 
       (not << String.isEmpty)
    |> validator "There is already an animal with that name!" form_name 
       (not << (flip Set.member) context.disallowedNames)
          
-- Helpers
         
validator : String -> FormLens field -> (field -> Bool) -> Form -> Form
validator errorMessage lens pred form =
  let
    formValue = lens.get form
  in
    case pred formValue.value of
      True -> 
        form
      False ->
        lens.set (invalidate formValue errorMessage) form
          |> form_isValid.set False

invalidate : FormValue t -> String -> FormValue t
invalidate formValue msg =
  FormValue Invalid formValue.value <| (Error, msg) :: formValue.commentary

