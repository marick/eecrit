module Animals.View exposing (view)

import Animals.Model exposing (Model)
import Animals.Msg exposing (Msg(Navigate), NavigationOperation(..))

import Animals.Pages.H exposing (PageChoice(..))
import Animals.Pages.Navigation as Navigation
import Animals.Pages.AddPage as AddPage
import Animals.Pages.AllPage as AllPage
import Animals.Pages.HelpPage as HelpPage

import Pile.Css.Bulma as Css
import Html exposing (..)

view : Model -> Html Msg
view model =
  div []
    [ Css.tabs model.page
        [ (AllPage, "View Animals", Navigation.gotoMsg AllPage)
        , (AddPage, "Add Animals", Navigation.gotoMsg AddPage)
        , (HelpPage, "Help", Navigation.gotoMsg HelpPage)
        ]
    , case model.page of
        AllPage -> AllPage.view model
        AddPage -> AddPage.view model
        HelpPage -> HelpPage.view model
    ]


