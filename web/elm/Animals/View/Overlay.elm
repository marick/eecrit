module Animals.View.Overlay exposing (view)

import Animals.Msg exposing (..)
import Animals.Model exposing (Model)
import Animals.Types.ModalOverlay exposing (..)

import Pile.Css.Bulma as Css
import Pile.Css.Bulma.Modal as Css
import Pile.Css.Bulma.Button as Css
import Pile.Calendar as Calendar
import Pile.DateHolder as DateHolder
import Html exposing (..)
import Html.Attributes exposing (..)




view : Model -> Maybe (Html Msg)                      
view model =
  case model.overlay of
    None -> Nothing
    AllPageCalendar -> viewCalendar model
    AllPageCalendarHelp -> allPageCalendarHelp model



viewCalendar model =                        
  let
    body = [ calendarWarning
           , Calendar.view
             (DateHolder.modalPickerDate model.effectiveDate)
             (OnAllPage << CalendarClick)
           ]
  in
    Just <| Css.saveCancelModal "Change the Date" body
      (OnAllPage SaveCalendarDate) (OnAllPage DiscardCalendarDate)
        

calendarWarning : Html msg
calendarWarning =
  p []
    [ span [class "icon is-danger"] [i [class "fa fa-exclamation-triangle"] []]
    , text """ Note: Changing the date will reload the animals.
            If you are in the middle of editing any animals, those changes
            will be lost. (Todo: Only show this message when animals are being
            edited.)
            """
    ]



--- Help

allPageCalendarHelp model =
  help "About the Effective Date"
    [ p [class "content"]
        [ text "The View Animals page shows animals as of a particular day, called the "
        , i [] [text "effective date" ]
        , text ". If you "
        , Css.helpTextPrimaryButton "Change"
        , text """ the effective date back to before a particular animal was
                added, that animal won't appear in the list.
                """
        ]
    , p [class "content"]
      [ text "You can edit an animal by clicking on the pencil icon "
      , Css.helpTextIcon "fa-pencil"
      , text """ . If you haven't changed the effective date, the change
              takes place today. But you can make a change retroactive by
              changing the effective date to the past, or you can schedule
              it for the future by changing the effective date to the future.
              """
      ]
    ]
        
help title body =
  Just <| Css.dismissableModal title body (SetOverlay None)
