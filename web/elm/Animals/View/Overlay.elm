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
    AddAnimalsHelp -> addAnimalsHelp model
    AnimalHistoryHelp -> animalHistoryHelp model
    FormHelp -> formHelp model
    Unimplemented -> unimplemented model

viewCalendar : Model -> Maybe (Html Msg)                     
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

unimplemented : Model -> Maybe (Html Msg)
unimplemented model =
  help "That Feature Isn't Implemented Yet"
    [ text """ The button is only there to suggest the sorts of things this app
            will eventually do.
            """
    ]

--- Help

animalHistoryHelp : Model -> Maybe (Html Msg)                     
animalHistoryHelp model =
  help "About Animal History"
    [ Css.contentP
        [ text """This page is only a sketch of how one kind of reporting will work.
                It shows that you'll be able to observe not only how animals
                have changed over time, but who made the changes and when.
                """
        ]
    , Css.contentP
        [ text """Importantly, this page or one like it will let you look
                at all the times an animal has been used (reserved). It will
                also make it easy to calculate particular totals and aggregate
                statistics, such as how many days per month an animal was used.
                """
        ]
    , Css.contentP
        [ text """However, in this sort of application, it's almost always the case
                that 
                """
        , i [] [text "someone"]
        , text """ will want a report the app can't generate. For that reason,
                it's important to allow data export so that data can be crunched
                with spreadsheets and similar tools. (Exporting for a spreadsheet
                doesn't work yet.)
                """
        ]
    , Css.contentP
        [ text """Given that a major use of the app will be demonstrating
                regulatory compliance, there will be a way to produce better
                (clearer, better looking) reports in PDF format.
                """
        ]
    ]

addAnimalsHelp : Model -> Maybe (Html Msg)                     
addAnimalsHelp model =
  help "About Adding Animals"
    [ Css.contentP
       [ text "The simplest way to add an animal is to select its species, then click "
        , Css.helpTextPrimaryButton "Click to add more information"
       , text """. You must then add a name. Optionally, you can add tags.
               (Later, you'll be able to add more than just tags.)
               """
       ]
    , Css.contentP
       [ text """By default, the animal will be created effective immediately.
               You can change the creation date with the 
               """
       , Css.helpTextPrimaryButton "Change date"
       , text " button. You're allowed to create animals in the past."
       ]
    , Css.contentP
      [ text """You'll often want to add several similar animals at once,
              perhaps five horses. 
              You can avoid having to re-enter the same information several times.
              Like this:
              """
      , ol []
        [li []
           [ text "Pick the desired species and click "
           , Css.helpTextPrimaryButton "Click to add more information"
           , text "."
           ]
        , li []
           [ text """Add the information common to all or most of the animals.
                   For example, you might add the tag "mare" and set the
                   creation date to next week.
                   """
           ]
        , li []
           [ text "Click the "
           , Css.helpTextIcon "fa-plus"
             , text " (copy) icon on the right side of the form, and create four copies. "
           ]

        , li []
           [ text """Now you can make the changes specific to each animal. You'll
                   have to give each its own name. You might also delete the "mare"
                   tag from one of them and change it to "gelding". 
                   """
           ]
        ]
      ]
    ]

formHelp : Model -> Maybe (Html Msg)
formHelp model =
  help "About Editing Animals"
    [ Css.contentP
       [ text "Please "
       , a [href "mailto:marick@exampler.com"] [text "let me know"]
       , text " what questions you have that should be answered here."
       ]
    ]


allPageFilterByHelp : Model -> Maybe (Html Msg)
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
  

allPageCalendarHelp : Model -> Maybe (Html Msg)
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
        
help : String -> List (Html Msg) -> Maybe (Html Msg)
help title body =
  Just <| Css.dismissableModal title body (SetOverlay None)
