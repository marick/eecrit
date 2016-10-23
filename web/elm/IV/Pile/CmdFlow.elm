module IV.Pile.CmdFlow exposing
  ( change
  , augment
  , chainLike
  )

type alias GetterSetter whole part =
  { getter : whole -> part
  , setter : whole -> part -> whole
  }

type alias PartTransform part msg =
  part -> (part, Cmd msg)


change : (GetterSetter whole part) ->
           (whole -> (PartTransform part msg) -> (whole, Cmd msg))
change {getter, setter} whole f =
  let
    (newPart, cmd) = f (getter whole)
  in
    (setter whole newPart, cmd)
      
augment : (GetterSetter whole part) ->
           ( (PartTransform part msg) -> (whole, Cmd msg) -> (whole, Cmd msg))
augment {getter, setter} f (whole, cmd) =
    let
      (newPart, newCmd) = f (getter whole)
    in
      ( setter whole newPart
      , Cmd.batch [cmd, newCmd]
      )
                
chainLike : whole -> List ( GetterSetter whole part, PartTransform part msg) ->
             (whole, Cmd msg)
chainLike whole list =
  let
    updater = \ (inWhat, f) soFar -> augment inWhat f soFar 
  in
    List.foldl updater (whole, Cmd.none) list
