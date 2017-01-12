module Animals.OutsideWorld.Update exposing (..)

import Animals.Msg exposing (..)
import Animals.Model exposing (..)
import Animals.Types.Basic exposing (..)
import Animals.View.PageFlash as PageFlash
import Pile.UpdateHelpers exposing (..)

update : OutsideLeakageOperation -> Model -> ( Model, Cmd Msg )
update op model =
  case op of
    HttpError context err ->
      model
        |> model_pageFlash.set (PageFlash.HttpErrorFlash context err)
        |> noCmd
