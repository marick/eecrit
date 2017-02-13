module Animals.View exposing (view)

import Animals.Msg exposing (..)
import Animals.Model exposing (Model)
import Animals.Msg exposing (Msg(Navigate), NavigationOperation(..))

import Animals.Pages.H exposing (PageChoice(..))
import Animals.Pages.Navigation as Navigation
import Animals.Pages.AddPage as AddPage
import Animals.Pages.AllPage as AllPage
import Animals.Pages.HelpPage as HelpPage
import Animals.Pages.HistoryPage as HistoryPage

import Pile.Css.Bulma as Css
import Pile.Css.Bulma.Modal as Css
import Html exposing (..)
import Html.Attributes exposing (..)
import Maybe.Extra as Maybe
import Pile.Calendar as Calendar
import Dict

view : Model -> Html Msg
view model =
  let
    parts =
      [ Just (tabs model)
      , Just (page model)
      , modal model
      ]
  in
    div [] (Maybe.values parts)

-- Private
      
tabs model =
  Css.tabs model.page
    ([ (AllPage, "View Animals", Navigation.gotoMsg AllPage)
    , (AddPage, "Add Animals", Navigation.gotoMsg AddPage)
    , (HelpPage, "Help", Navigation.gotoMsg HelpPage)
    ] ++ historyPages model)

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

page model  = 
  case model.page of
    AllPage -> AllPage.view model
    AddPage -> AddPage.view model
    HelpPage -> HelpPage.view model
    HistoryPage id -> HistoryPage.view id model

modal model =
  if model.effectiveDate.datePickerOpen then
    let
      body = [ warning
             , Calendar.view model.effectiveDate (OnAllPage << CalendarClick)
             ]
    in
      Just <| Css.modal "Change the Date" body
        (OnAllPage SaveCalendarDate) (OnAllPage DiscardCalendarDate)
  else
    Nothing


warning =
  p []
    [ span [class "icon is-danger"] [i [class "fa fa-exclamation-triangle"] []]
    , text """ Note: Changing the date will reload the animals.
            If you are in the middle of editing any animals, those changes
            will be lost. (Todo: Only show this message when animals are being
            edited.)
            """
    ]
