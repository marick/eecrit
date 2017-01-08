module Pile.UpdatingLens exposing
  ( UpdatingLens
  , lens
  , compose
  , toMonocle
  )

import Monocle.Lens as Lens exposing (Lens)

type alias GetPart whole part =
  whole -> part
type alias SetPart whole part =
  part -> whole -> whole
type alias UpdatePart whole part =
  (part -> part) -> whole -> whole

type alias UpdatingLens whole part =
  { get : GetPart whole part
  , set : SetPart whole part
  , update : UpdatePart whole part
  }

lens : GetPart whole part -> SetPart whole part -> UpdatingLens whole part
lens getPart setPart =
  { get = getPart
  , set = setPart
  , update = lensUpdate getPart setPart
  }

compose : UpdatingLens whole intermediate -> UpdatingLens intermediate part
        -> UpdatingLens whole part
compose left right = 
  let
    left_ = toMonocle left
    right_ = toMonocle right
    composed = Lens.compose left_ right_
  in
    lens composed.get composed.set

-- For internal use (by this and Optional)
  
toMonocle : UpdatingLens whole part -> Lens whole part
toMonocle u =
  { get = u.get
  , set = u.set
  }

lensUpdate : GetPart whole part -> SetPart whole part -> (part -> part)
             -> (whole -> whole)
lensUpdate getPart setPart partTransformer whole =
  setPart (whole |> getPart |> partTransformer) whole

