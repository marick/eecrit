module Pile.UpdateHelpers exposing (..)

{-| Convert a model into an update return value with no `Cmd`. 
Typically used at the end of a |> pipeline that transforms a model.
-}
noCmd : t -> (t, Cmd msg)
noCmd model = model ! []

{-| Given a command and a model, create a `(model, cmd)`.
-}
addCmd : Cmd msg -> model -> (model, Cmd msg)
addCmd cmd model =
 (model, cmd)

{-| Given a list of commands and a model, create a `(model, batched-cmds)`.
-}
addCmds : List (Cmd msg) -> model -> (model, Cmd msg)
addCmds cmds model =
 addCmd (Cmd.batch cmds) model

