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
    AllPageFilterByHelp -> allPageFilterByHelp model
    FormHelp -> formHelp model

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

formHelp model =
  help "About Editing Animals"
    [ Css.contentP
       [ text "Please "
       , a [href "mailto:marick@exampler.com"] [text "let me know"]
       , text " what questions you have that should be answered here."
       ]
    ]


allPageFilterByHelp model =
  help "About Filtering Animals"
    [ Css.contentP
       [ text """You can reduce the number of animals shown on the page with
               these three filters.
               """
       ]
    , Css.contentP
       [ text """
               If you want to see only animals of a particular species, pick
               that species from the Species dropdown.
               """
       ]
    , Css.contentP
       [ text """
               If you want to see a particular animal, begin typing its name in
               the Name box. You don't have to worry about capital or lower-case
               letters. As you'll see if you try it, you don't have to type the
               full name, only the first few characters.
               """
       ]
    , Css.contentP
       [ text """
               To see only animals with particular tags, use the Tag box. Like
               the Name box, you'll only need to type a few characters. For example,
               if you type "s", you'll see an animal tagged 
               """
       , Css.readOnlyTag "skittish"
       , text " and one tagged "
       , Css.readOnlyTag "stallion"
       , text """. If you then add a "k", only the first animal will remain.
               """
       ]

    , Css.contentP
       [ text """You can use more than one filter. Only animals that pass all
               the filters will be shown. For example, selecting "bovine" and
               typing "skit" in the Tags field will show you only skittish cattle.
               
               """
       ]

    ]
  

allPageCalendarHelp model =
  help "About the Effective Date"
    [ Css.contentP
        [ text "The View Animals page shows animals as of a particular day, called the "
        , i [] [text "effective date" ]
        , text ". If you "
        , Css.helpTextPrimaryButton "Change"
        , text """ the effective date back to before a particular animal was
                added, that animal won't appear in the list.
                """
        ]
    , Css.contentP
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
