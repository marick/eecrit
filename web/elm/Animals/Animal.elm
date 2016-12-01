module Animals.Animal exposing (..)

import Animals.Types exposing (..)
import Animals.Msg exposing (..)
import Animals.OutsideWorld as OutsideWorld
import Animals.Navigation as MyNav

import Navigation
import String
import List
import Date exposing (Date)
import Date.Extra
import Dict exposing (Dict)
import Pile.Calendar exposing (EffectiveDate(..))

toState newState animal =
  { animal | displayState = newState }

setEditedName newName animal =
  let
    setter editableCopy = { editableCopy | name = newName }
  in
    { animal | editableCopy = Maybe.map setter animal.editableCopy }

makeEditableCopy animal =
  let
    extracted =
      { name = animal.name
      , tags = animal.tags
      }
  in
    { animal | editableCopy = Just extracted }


-- TODO: Lack of valid editable copy should make Save unclickable.
      
replaceEditableCopy animal =
  case animal.editableCopy of
    Nothing -> -- impossible
      animal
    (Just newValues) -> 
      { animal
        | name = newValues.name
        , tags = newValues.tags
          
        , editableCopy = Nothing
      }
  
cancelEditableCopy animal = 
  { animal | editableCopy = Nothing }
      
transformAnimal transformer id animals =
  let
    doOne animal =
      if animal.id == id then
        transformer animal
      else
        animal
  in
    List.map doOne animals

      
