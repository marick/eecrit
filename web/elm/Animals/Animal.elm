module Animals.Animal exposing (..)

import Animals.Types exposing (..)
import Animals.Msg exposing (..)
import List
import List.Extra as List

toState newState animal =
  { animal | displayState = newState }

setEditedName newName animal =
  let
    setter editableCopy = { editableCopy | name = newName }
  in
    { animal | editableCopy = Maybe.map setter animal.editableCopy }

deleteTag name animal = 
  let
    setter editableCopy =
      { editableCopy | tags = List.remove name animal.tags }
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

      
