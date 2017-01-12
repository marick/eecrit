module Animals.Animal.Validation exposing (..)

import Dict exposing (Dict)
import List.Extra as List
import Pile.Bulma as Bulma exposing
  (FormStatus(..), FormValue, Urgency(..), Validity(..))
import Pile.Namelike as Namelike 
import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Form as Form

animalNames : Dict Id Displayed -> List String
animalNames displayables =
  displayables
    |> Dict.values
    |> List.map displayed_name.get


context : Dict Id Displayed -> Maybe Animal -> ValidationContext 
context displayables origin =
  let
    augment xs =
      case origin of
        Nothing -> xs
        Just animal -> xs |> List.remove animal.name
  in
    { disallowedNames =
        animalNames displayables |> augment
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
        lens.set (Bulma.invalidate errorMessage formValue) form
          |> form_status.set SomeBad
      False ->
        form

