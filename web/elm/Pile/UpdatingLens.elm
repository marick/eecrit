module Pile.UpdatingLens exposing
  ( UpdatingLens
  , lens
  , compose
  , toMonocle
  )

import Monocle.Lens as Lens exposing (Lens)


type alias UpdatingLens whole part =
  { get : whole -> part
  , set : part -> whole -> whole
  , update : (part -> part) -> whole -> whole
  }

lens getPart setPart =
  { get = getPart
  , set = setPart
  , update = lensUpdate getPart setPart
  }

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

lensUpdate getPart setPart partTransformer whole =
  setPart (whole |> getPart |> partTransformer) whole

