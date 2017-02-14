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

import Animals.Types.Basic exposing (..)
import Animals.Types.Lenses exposing (..)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Displayed as Displayed exposing (Displayed)

import Pile.Css.H as Css
import Pile.Namelike as Namelike exposing (Namelike)

import Dict exposing (Dict)
import Set

animalNames : Dict Id Displayed -> List String
animalNames displayables =
  displayables
    |> Dict.values
    |> List.map displayed_name.get
    |> List.filter Namelike.isPresent


context : Dict Id Displayed -> List Namelike -> Form.ValidationContext 
context displayables notDuplicates =
  let
    nameSet = animalNames displayables |> Set.fromList
    safeSet = notDuplicates |> Set.fromList
    disallowedSet = Set.diff nameSet safeSet
  in
    { disallowedNames = Set.toList disallowedSet
    }

forceValid : Form -> Form 
forceValid form =
  { form
    | status = Css.AllGood
    , name = Css.freshValue form.name.value
  } 
    
validate : Form.ValidationContext -> Form -> Form
validate context =
  forceValid >> validateName context.disallowedNames

--  Validators
  
validateName : List Namelike -> Form -> Form
validateName nameClashes form =
  form 
    |> validator "The animal has to have a name!" form_name 
       Namelike.isBlank
    |> validator "There is already an animal with that name!" form_name
       (flip Namelike.isMember <| nameClashes)

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
