module Animals.Logic.HistoryPageOp exposing (..)

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Pages.H exposing (PageChoice(..))
import Animals.Types.AnimalHistory as AnimalHistory exposing(History)
import Animals.Pages.Navigation as Navigation
import Pile.UpdateHelpers exposing (..)
import Dict
import List.Extra as List

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
      let
        next = nextPage history.id model.historyOrder
      in
        model
          |> forgetHistoryPage history.id
          |> addCmd (Navigation.toPageChangeCmd next)
      
nextPage : Id -> List Id -> PageChoice
nextPage id list = 
  case List.elemIndex id list of
    Nothing -> -- impossible
      AllPage
    Just index ->
      case (List.getAt (index-1) list, List.getAt (index+1) list) of
        (_, Just nextId) -> -- preferentially move right
          HistoryPage nextId
        (Just nextId, _) -> 
          HistoryPage nextId -- otherwise, left
        _ -> -- nowhere to go
         AllPage
              
