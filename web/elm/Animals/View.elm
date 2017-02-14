module Animals.View exposing (view)

import Animals.Msg exposing (..)
import Animals.Model exposing (Model)
import Animals.Pages.H exposing (PageChoice(..))
import Animals.Pages.Navigation as Navigation
import Animals.Pages.AddPage as AddPage
import Animals.Pages.AllPage as AllPage
import Animals.Pages.HelpPage as HelpPage
import Animals.Pages.HistoryPage as HistoryPage

import Animals.View.Overlay as Overlay


import Pile.Css.Bulma as Css
import Html exposing (..)
import Maybe.Extra as Maybe
import Dict

view : Model -> Html Msg
view model =
  let
    parts =
      [ Just (tabs model)
      , Just (page model)
      , Overlay.view model
      ]
  in
    div [] (Maybe.values parts)

-- Private

tabs : Model -> Html Msg
tabs model =
  Css.tabs model.page
    ([ (AllPage, "View Animals", Navigation.gotoMsg AllPage)
    , (AddPage, "Add Animals", Navigation.gotoMsg AddPage)
    , (HelpPage, "Help", Navigation.gotoMsg HelpPage)
    ] ++ historyPages model)

historyPages : Model -> List (PageChoice, String, Msg)    
historyPages model =
  model.historyOrder
    |> List.map ((flip Dict.get) model.historyPages)
    |> Maybe.values
    |> List.map (\history ->
                   ( HistoryPage history.id
                   , history.name
                   , Navigation.gotoMsg (HistoryPage history.id)
                   )
                )

page : Model -> Html Msg
page model  = 
  case model.page of
    AllPage -> AllPage.view model
    AddPage -> AddPage.view model
    HelpPage -> HelpPage.view model
    HistoryPage id -> HistoryPage.view id model

