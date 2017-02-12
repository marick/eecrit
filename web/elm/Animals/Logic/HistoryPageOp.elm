module Animals.Logic.HistoryPageOp exposing (..)

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.AnimalHistory as AnimalHistory exposing(History)
import Pile.UpdateHelpers exposing (..)
import Dict

-- TODO: `forwardToPageOp` is not the clearest of names. Rethink all the
-- `forwardTo...` functions.

forwardToPageOp : Id -> HistoryPageOperation -> Model -> (Model, Cmd Msg)
forwardToPageOp id op model =
  case Dict.get id model.historyPages of
    Nothing -> 
      model |> noCmd -- Todo: a command to log the error
    Just history -> 
      update op history model


update : HistoryPageOperation -> History -> Model -> (Model, Cmd Msg)
update op history model =
  case op of 
    SetHistory entries ->
      let
        improvedHistory = { history | entries = entries }
      in
        model |> upsertHistoryPage history.id improvedHistory |> noCmd

    CloseHistoryPage ->
      model |> noCmd
      
