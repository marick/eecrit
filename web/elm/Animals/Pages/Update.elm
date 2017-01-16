module Animals.Pages.Update exposing (update)

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)
import Animals.Pages.Navigation as Page

import Pile.UpdateHelpers exposing(..)

update : NavigationOperation -> Model -> ( Model, Cmd Msg )
update op model =
  case op of 
    NoticeChange location ->
      model |> model_page.set (Page.fromLocation location) |> noCmd
      
    StartChange page ->
      ( model, Page.toPageChangeCmd page )
      
