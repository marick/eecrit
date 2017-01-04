module Animals.Animal.Validation exposing (..)

import Dict exposing (Dict)
import String
import List.Extra as List
import Pile.Bulma as Bulma exposing
  (FormStatus(..), FormValue, Urgency(..), Validity(..))
import Pile.Namelike as Namelike 
import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Form as Form


animalNames : Dict Id DisplayedAnimal -> List String
animalNames animals =
  animals
    |> Dict.values
    |> List.map displayedAnimal_name.get


context : Dict Id DisplayedAnimal -> Animal -> ValidationContext 
context animals changingAnimal  =
  { disallowedNames = animalNames animals |> List.remove changingAnimal.name
  }

validate : ValidationContext -> Form -> Form
validate context form =
  Form.assumeValid form 
    |> validateName context

--  Validators
  
validateName : ValidationContext -> Form -> Form
validateName context form =
  form 
    |> validator "The animal has to have a name!" form_name 
       Namelike.isBlank
    |> validator "There is already an animal with that name!" form_name
       (flip Namelike.isMember <| context.disallowedNames)
          
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
          |> form_status.set SomeBad

invalidate : FormValue t -> String -> FormValue t
invalidate formValue msg =
  FormValue Invalid formValue.value <| (Error, msg) :: formValue.commentary

