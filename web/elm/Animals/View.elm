module Animals.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (programWithFlags)
import Html.Events as Events
import Pile.Bulma as Bulma

import Animals.Msg exposing (Msg(..))
import Animals.Main exposing (Model)
import Animals.Navigation as MyNav

import Animals.View.AllPageView as AllPage
import Animals.View.AddPageView as AddPage
import Animals.View.HelpPageView as HelpPage

view : Model -> Html Msg
view model =
  div []
    [ Bulma.tabs model.page
        [ (MyNav.AllPage, "View Animals", NavigateToAllPage)
        , (MyNav.AddPage, "Add Animals", NavigateToAddPage)
        , (MyNav.HelpPage, "Help", NavigateToHelpPage)
        ]
    , case model.page of
        MyNav.AllPage -> AllPage.view model
        MyNav.AddPage -> AddPage.view model
        MyNav.HelpPage -> HelpPage.view model
    ]
