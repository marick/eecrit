module Animals.OutsideWorld.Update exposing (..)

import Animals.Msg exposing (..)
import Animals.Model exposing (..)
import Animals.Pages.PageFlash as Flash
import Pile.UpdateHelpers exposing (..)

update : OutsideLeakageOperation -> Model -> ( Model, Cmd Msg )
update op model =
  case op of
    HttpError context err ->
      model
        |> model_pageFlash.set (Flash.HttpErrorFlash context err)
        |> noCmd
