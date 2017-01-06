module Pile.UpdateHelpers exposing (..)

{-| Convert a model into an update return value with no `Cmd`. 
Typically used at the end of a |> pipeline that transforms a model.
-}
noCmd : t -> (t, Cmd msg)
noCmd model = model ! []

{-| Given a pair `(model, stuff)`, create a `(model, Cmd Msg)` by applying
the given function to the `stuff`. 
-}
makeCmd : (stuff -> Cmd msg) -> (model, stuff) -> (model, Cmd msg)
makeCmd f (model, stuff) =
  ( model, f stuff)

