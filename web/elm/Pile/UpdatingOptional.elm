module Pile.UpdatingOptional exposing
  ( UpdatingOptional
  , opt
  , extractOptional
  , composeLens
  )

import Monocle.Lens as Lens exposing (Lens)
import Monocle.Optional as Optional exposing (Optional)
import Pile.UpdatingLens as UpdatingLens exposing (UpdatingLens)
import Maybe.Extra as Maybe


type alias UpdatingOptional whole part =
  { getOption : whole -> (Maybe part)
  , set : part -> whole -> whole
  , maybeUpdate : (part -> part) -> whole -> whole
  }

opt getPartMaybe setPart =
  { getOption = getPartMaybe
  , set = setPart
  , maybeUpdate = optionalUpdate getPartMaybe setPart
  }
    
toMonocle : UpdatingOptional whole part -> Optional whole part
toMonocle u =
  { getOption = u.getOption
  , set = u.set
  }

composeLens : UpdatingOptional whole part -> UpdatingLens part subpart -> UpdatingOptional whole subpart
composeLens left right = 
  let
    left_ = toMonocle left
    right_ = UpdatingLens.extractLens right
    composed = Optional.composeLens left_ right_
  in
    opt composed.getOption composed.set


optionalUpdate getPartMaybe setPart partTransformer whole =
  let
    whenPartExistsF part = setPart (partTransformer part) whole
  in
    Maybe.unwrap whole whenPartExistsF (getPartMaybe whole)
  
