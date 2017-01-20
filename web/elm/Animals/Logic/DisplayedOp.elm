module Animals.Logic.DisplayedOp exposing (forwardToDisplayed)

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Animals.Types.Conversions as Convert
import Animals.Types.Lenses exposing (..)

import Animals.View.AnimalFlash as AnimalFlash

import Pile.UpdateHelpers exposing (..)
import Pile.ConstrainedStrings as Constrained

{-| Note that displayed operations do NOT empty the flash. This is kind of a
    kludge.
-}

forwardToDisplayed : Id -> DisplayedOperation -> Model -> (Model, Cmd Msg)
forwardToDisplayed id op model =
  case getDisplayed id model of
    Nothing -> 
      model |> noCmd -- Todo: a command to log the error
    Just displayed -> 
      update op displayed model

update : DisplayedOperation -> Displayed -> Model -> (Model, Cmd Msg)
update op displayed model =
  case op of
    BeginGatheringCopyInfo ->
        model
          |> upsertDisplayed (withGatherFlash displayed "1")
          |> noCmd

    UpdateCopyCount countString ->
        model
          |> upsertDisplayed (withValidatedGatherFlash displayed countString)
          |> noCmd

withGatherFlash displayed string = 
  displayed_flash.set
    (AnimalFlash.CopyInfoNeeded (displayed_id.get displayed) string)
    displayed

withValidatedGatherFlash displayed string = 
  case Constrained.isPotentialIntString string of
    True -> withGatherFlash displayed string
    False -> displayed
