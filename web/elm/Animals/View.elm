module Animals.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.Bulma as Bulma

import Animals.Msg exposing (Msg(..))
import Animals.Model exposing (Model)

import Animals.Pages.AllPage as AllPage
import Animals.Pages.AddPage as AddPage
import Animals.Pages.HelpPage as HelpPage
import Animals.Pages.H exposing (PageChoice(..))

view : Model -> Html Msg
view model =
  div []
    [ Bulma.tabs model.page
        [ (AllPage, "View Animals", StartPageChange AllPage)
        , (AddPage, "Add Animals", StartPageChange AddPage)
        , (HelpPage, "Help", StartPageChange HelpPage)
        ]
    , case model.page of
        AllPage -> AllPage.view model
        AddPage -> AddPage.view model
        HelpPage -> HelpPage.view model
    ]
