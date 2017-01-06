module Animals.View exposing (view)

import Animals.Model exposing (Model)
import Animals.Msg exposing (Msg(Page), PageOperation(..))

import Animals.Pages.H exposing (PageChoice(..))
import Animals.Pages.AllPage as AllPage
import Animals.Pages.AddPage as AddPage
import Animals.Pages.HelpPage as HelpPage

import Pile.Bulma as Bulma
import Html exposing (..)

view : Model -> Html Msg
view model =
  div []
    [ Bulma.tabs model.page
        [ (AllPage, "View Animals", Page <| StartChange AllPage)
        , (AddPage, "Add Animals", Page <| StartChange AddPage)
        , (HelpPage, "Help", Page <| StartChange HelpPage)
        ]
    , case model.page of
        AllPage -> AllPage.view model
        AddPage -> AddPage.view model
        HelpPage -> HelpPage.view model
    ]

