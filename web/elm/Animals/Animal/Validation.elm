module Animals.Animal.Validation exposing (..)

import Dict exposing (Dict)
import List.Extra as List
import Animals.Types.Basic exposing (..)
import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Pile.Css.H as Css
import Pile.Css.Bulma as Css
import Pile.Namelike as Namelike 
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Form as Form

animalNames : Dict Id Displayed -> List String
animalNames displayables =
  displayables
    |> Dict.values
    |> List.map displayed_name.get


context : Dict Id Displayed -> Maybe Animal -> Form.ValidationContext 
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

validate : Form.ValidationContext -> Form -> Form
validate context form =
  Form.assumeValid form 
    |> validateName context

--  Validators
  
validateName : Form.ValidationContext -> Form -> Form
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
        lens.set (Css.invalidate errorMessage formValue) form
          |> form_status.set Css.SomeBad
      False ->
        form

