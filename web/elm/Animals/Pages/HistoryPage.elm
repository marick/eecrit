module Animals.Pages.HistoryPage exposing (..)

import Animals.Pages.H exposing (PageChoice(..))
import Animals.Pages.Navigation as Navigation
import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.Css.Bulma as Css
import Pile.Css.Bulma.Button as Css
import Date
import Pile.Date as Date
import Date.Extra as Date
import Pile.HtmlShorthand exposing (..)
import Animals.Types.Basic exposing (..)
import Animals.Types.AnimalHistory as AnimalHistory
import Animals.Msg exposing (..)

sample =
  { id = "irrelevant"
  , name = "irrelevant"
  , entries =
      [ { audit = {author = "dmorin", date = Date.fromCalendarDate 2016 Date.Dec 12 }
        , effectiveDate = Date.fromCalendarDate 2017 Date.Jan 1
        , nameChange = Just "bossie"
        , newTags = [ "foo", "bar" ]
        , deletedTags = []
        }
      , { audit = {author = "smith", date = Date.fromCalendarDate 2017 Date.Feb 6 }
        , effectiveDate = Date.fromCalendarDate 2017 Date.Feb 6
        , nameChange = Nothing
        , newTags = [ ]
        , deletedTags = ["foo"]
        }
      ]
  }

view : Id -> model -> Html Msg
view id model =
  div []
    [ controls id
    , historyTable sample
    , updateWarning
    ]


controls id =
  Css.centeredColumns
    [ Css.column 11
        [ Css.messageView
            [ text "What next?"
            , pageHelp Css.rightIcon
            ]
            [ Css.distributeHorizontally
                [ Css.primaryButton "Export for spreadsheet" {click = Just NoOp}
                , pageCloseButton id                    
                ]
            ]
        ]
    ]

pageHelp iconType = 
  iconType "fa-question-circle" "Help for this page" NoOp

pageCloseButton id =
  a [ class "button is-danger"
    , onClickPreventingDefault (CloseHistoryPage id)
    ]
    [ span [] [ text "Close tab" ] 
    , span [class "icon is-small"] [i [class "fa fa-times"] []]
    ]



historyTable history =
  table [class "table is-striped is-narrow"]
    [ thead []
        [ tr []
           [ th [] [text "Date"]
           , th [] [text "Name"]
           , th [] [text "New tags"]
           , th [] [text "Removed tags"]
           , th [] [text "Audit Trail"]
           ]
        ]
    , tbody []
        (List.map historyRow history.entries)
    ]

historyRow entry =
  let
    dash = hr [style [("width", "50%")]] []
           
    stringChange maybeString =
      case maybeString of
        Nothing -> dash
        Just s -> text s
                  
    listChange changes =
      case List.isEmpty changes of
        True -> dash
        False -> text <| String.join ", " changes
    
    date = text <| Date.humane entry.effectiveDate
    name = stringChange entry.nameChange
    newTags = listChange entry.newTags
    deletedTags = listChange entry.deletedTags
    audit = text <| "by " ++ entry.audit.author ++ " on " ++ Date.humane entry.audit.date
  in 
    tr []
      [ td [] [ date ]
      , td [] [ name ]
      , td [] [ newTags ]
      , td [] [ deletedTags ]
      , td [] [ audit ]
      ]
      
    
updateWarning =
  div [class "card"]
    [ header [class "card-header"]
        [ p [class "card-header-title"]
            [text "This page does not update"]
        ]
    , div [class "card-content"]
      [ div [class "content"]
          [ text "If you now change this animal on the "
          , a [ href "#"
              , onClickPreventingDefault <| Navigation.gotoMsg AllPage
              ]
              [text "View Animals"]
          , text " page, those changes won't show up here. You'll need to click the animal's "
          , a [ class "button is-primary is-small" ]
            [ text "See History"]
          , text " button to refresh this page. (Todo: fix this.)"
          ]
      ]
    ]
    
