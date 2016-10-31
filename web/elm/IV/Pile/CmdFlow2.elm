module IV.Pile.CmdFlow2 exposing
  ( flow
  , update
  )

import Monocle.Lens exposing (..)


flow : model -> (model, Cmd msg)
flow model =
  (model, Cmd.none)

update : (Lens whole part) -> (part -> (part, Cmd msg)) -> (whole, Cmd msg) -> (whole, Cmd msg)
update lens f (whole, cmd) =
  let
    (newPart, newCmd) = f (lens.get whole)
  in
    ( lens.set newPart whole
    , Cmd.batch [cmd, newCmd]
    )
  
