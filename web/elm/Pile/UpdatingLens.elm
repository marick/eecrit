module Pile.UpdatingLens exposing
  ( UpdatingLens
  , lens
  , extractLens
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

extractLens : UpdatingLens whole part -> Lens whole part
extractLens u =
  { get = u.get
  , set = u.set
  }

lensUpdate getPart setPart partTransformer whole =
  setPart (whole |> getPart |> partTransformer) whole

