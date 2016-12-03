module Animals.Animal exposing (..)

import Animals.Types exposing (..)
import Animals.Lenses exposing (..)
import Animals.Msg exposing (..)
import Dict
import List
import List.Extra as List
import Maybe.Extra as Maybe

deleteTag name =
  animal_editedTags.maybeUpdate (List.remove name)

noReallyThereIsAnEditableCopyWhenThisIsCalled animal =
  case animal.editableCopy of
    Nothing ->
      ([], "this will never happen")
    (Just copy) ->
      (copy.tags, copy.tentativeTag)
    
promoteTentativeTag animal =
  let
    (tags, newTag) = noReallyThereIsAnEditableCopyWhenThisIsCalled animal
  in
    animal
      |> animal_editedTags.set (newTag :: tags)
      |> animal_tentativeTag.set ""

makeEditableCopy animal =
  animal_editableCopy.set
    { name = animal.name
    , tags = animal.tags
    , tentativeTag = ""
    }
    animal


-- TODO: Lack of valid editable copy should make Save unclickable.
      
saveEditableCopy animal =
  case animal.editableCopy of
    Nothing -> -- impossible
      animal
    (Just newValues) -> 
      { animal
        | name = newValues.name
        , tags = newValues.tags
          
        , editableCopy = Nothing
      }

-- TODO: It's interesting that there's no way to
-- use an Optional to set the value to Nothing.
cancelEditableCopy animal =
  { animal | editableCopy = Nothing }

-- Animal groupings

asDict animals =
  let
    tuple animal = (animal.id, animal)
  in
    animals |> List.map tuple |> Dict.fromList
    
transformAnimal transformer id animals =
  Dict.update id (Maybe.map transformer) animals
