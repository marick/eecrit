module Animals.Lenses exposing (..)

import Animals.Types exposing (..)
import Monocle.Lens as Lens exposing (Lens)
import Monocle.Optional as Optional exposing (Optional)
import Monocle.Common as Common
import List.Extra as List
import Maybe.Extra as Maybe
import Maybe exposing (andThen)

type alias UpdatingLens whole part =
  { get : whole -> part
  , set : part -> whole -> whole
  , update : (part -> part) -> whole -> whole
  }

type alias UpdatingOptional whole part =
  { getOption : whole -> (Maybe part)
  , set : part -> whole -> whole
  , maybeUpdate : (part -> part) -> whole -> whole
  }

model_page = lens .page (\ p w -> { w | page = p })
model_today = lens .today (\ p w -> { w | today = p })
model_animals = lens .animals (\ p w -> { w | animals = p })

animal_displayState = lens .displayState (\ p w -> { w | displayState = p })

animal_editableCopy = opt .editableCopy (\ p w -> { w | editableCopy = Just p })
editableCopy_name = lens .name (\ p w -> { w | name = p })
editableCopy_tags = lens .tags (\ p w -> { w | tags = p })
                            
composeLens : UpdatingOptional whole part -> UpdatingLens part subpart -> UpdatingOptional whole subpart
composeLens left right = 
  let
    left_ = extractOptional left
    right_ = extractLens right
    composed = Optional.composeLens left_ right_
  in
    opt composed.getOption composed.set

animal_editedName = composeLens animal_editableCopy editableCopy_name
animal_editedTags = composeLens animal_editableCopy editableCopy_tags
      

--- Implementation

lens getPart setPart =
  { get = getPart
  , set = setPart
  , update = lensUpdate getPart setPart
  }

extractLens : UpdatingLens whole part -> Lens whole part
extractLens u =
  { get = u.get
  , set = u.set
  }

lensUpdate getPart setPart partTransformer whole =
  setPart (whole |> getPart |> partTransformer) whole


opt getPartMaybe setPart =
  { getOption = getPartMaybe
  , set = setPart
  , maybeUpdate = optionalUpdate getPartMaybe setPart
  }
    
extractOptional : UpdatingOptional whole part -> Optional whole part
extractOptional u =
  { getOption = u.getOption
  , set = u.set
  }

optionalUpdate getPartMaybe setPart partTransformer whole =
  let
    whenPartExistsF part = setPart (partTransformer part) whole
  in
    Maybe.unwrap whole whenPartExistsF (getPartMaybe whole)
        
        
  
