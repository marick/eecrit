module Animals.View.Overlay exposing (view)

import Animals.Msg exposing (..)
import Animals.Model exposing (Model)
import Animals.Types.ModalOverlay exposing (..)

import Pile.Css.Bulma.Modal as Css
import Pile.Calendar as Calendar
import Pile.DateHolder as DateHolder
import Html exposing (..)
import Html.Attributes exposing (..)




view : Model -> Maybe (Html Msg)                      
view model =
  case model.overlay of
    None -> 
      Nothing
    AllPageCalendar -> 
      let
        body = [ warning
               , Calendar.view
                 (DateHolder.modalPickerDate model.effectiveDate)
                 (OnAllPage << CalendarClick)
               ]
      in
        Just <| Css.saveCancelModal "Change the Date" body
          (OnAllPage SaveCalendarDate) (OnAllPage DiscardCalendarDate)


warning : Html msg
warning =
  p []
    [ span [class "icon is-danger"] [i [class "fa fa-exclamation-triangle"] []]
    , text """ Note: Changing the date will reload the animals.
            If you are in the middle of editing any animals, those changes
            will be lost. (Todo: Only show this message when animals are being
            edited.)
            """
    ]
