module Animals.Logic.Validation exposing
  ( context
  , validate
  )

{- The validation context is calculated from the entire model in order
to constrain correct values for a particular field in a particular animal.

Not sure yet how aggressive to be about validation. Right now, only the
name field is validated and only when it actually changes. As a natural consequence, 
that means that the starting message for a new form ("please fill in this empty field") can be different than an error message. But that's fragile. 

TODO: Perhaps best to go for complete safety: revalidate every form upon every
redisplay, then back off if that's too slow. 

TODO: Name validation should somehow include current tentative names
as well as the animal names. (Consider the case where two names are being
edited at the same time, with various sequencings of Saves.)
-}

import Dict exposing (Dict)
import List.Extra as List
import Animals.Types.Basic exposing (..)
import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Pile.Css.H as Css
import Pile.Namelike as Namelike 
import Animals.Types.Lenses exposing (..)

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

forceValid : Form -> Form 
forceValid form =
  { form
    | status = Css.AllGood
    , name = Css.freshValue form.name.value
  } 
    
validate : Form.ValidationContext -> Form -> Form
validate context =
  forceValid >> validateName context

--  Validators
  
validateName : Form.ValidationContext -> Form -> Form
validateName context form =
  form 
    |> validator "The animal has to have a name!" form_name 
       Namelike.isBlank
    |> validator "There is already an animal with that name!" form_name
       (flip Namelike.isMember <| context.disallowedNames)
          
-- Helpers
         
validator : String -> FormValueLens field -> (field -> Bool) -> Form -> Form
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

