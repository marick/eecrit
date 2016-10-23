module IV.Pile.Effects exposing
  ( change
  , chain
  )

type alias GetterSetter whole part =
  { getter : whole -> part
  , setter : whole -> part -> whole
  }

type alias PartTransform part msg =
  part -> (part, Cmd msg)
  
change : (GetterSetter whole part) ->
           (whole -> (PartTransform part msg) -> (whole, Cmd msg))
change {getter, setter} =
  \ whole f -> 
    let
      (newPart, cmd) = f (getter whole)
    in
      (setter whole newPart, cmd)

augment : (GetterSetter whole part) ->
           ( (whole, Cmd msg) -> (PartTransform part msg) -> (whole, Cmd msg))
augment {getter, setter} =
  \ (whole, cmd) f -> 
    let
      (newPart, newCmd) = f (getter whole)
    in
      ( setter whole newPart
      , Cmd.batch [cmd, newCmd]
      )
                
chain : whole -> List ( GetterSetter whole part, PartTransform part msg) ->
             (whole, Cmd msg)
chain whole list =
  let
    updater = \ (inWhat, f) soFar -> augment inWhat soFar f
  in
    List.foldl updater (whole, Cmd.none) list
  

