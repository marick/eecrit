module Animals.Pages.HistoryPage exposing (..)

import Animals.Msg exposing (..)
import Animals.Model exposing (Model)

import Animals.Types.Basic exposing (..)
import Animals.Types.AnimalHistory as AnimalHistory
import Animals.Types.ModalOverlay as Overlay

import Animals.Pages.H exposing (PageChoice(..))
import Animals.Pages.Navigation as Navigation

import Pile.Css.Bulma as Css
import Pile.Css.Bulma.Button as Css
import Pile.Date as Date
import Pile.HtmlShorthand exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Dict

view : Id -> Model -> Html Msg
view id model =
  case Dict.get id model.historyPages of
    Nothing ->
      div [class "card"]
        [ div [class "card-content"]
            [ Css.contentP
                [ text """In this stage of development, there's a technical 
                        limitation that breaks certain ways of "returning"
                        to an animal's history.
                        """
                ]
            , Css.contentP
              [ text "Sorry about that." ]
            ]
        ]
        
    Just history -> 
      div []
        [ controls id
        , historyTable history
        , updateWarning
        ]

controls : Id -> Html Msg
controls id =
  Css.centeredColumns
    [ Css.column 11
        [ Css.messageView
            [ text "What next?"
            , pageHelp Css.rightIcon
            ]
            [ Css.distributeHorizontally
                [ Css.primaryButton "Export for spreadsheet" unimplemented
                , Css.primaryButton "PDF report" unimplemented
                , pageCloseButton id                    
                ]
            ]
        ]
    ]

unimplemented = {click = Just <| SetOverlay Overlay.Unimplemented}
    
pageHelp : Css.IconExpander Msg -> Html Msg
pageHelp iconType = 
  iconType "fa-question-circle" "Help for this page"
    (SetOverlay Overlay.AnimalHistoryHelp)

pageCloseButton : Id -> Html Msg    
pageCloseButton id =
  a [ class "button is-danger"
    , onClickPreventingDefault (OnHistoryPage id CloseHistoryPage)
    ]
    [ span [] [ text "Close tab" ] 
    , span [class "icon is-small"] [i [class "fa fa-times"] []]
    ]


historyTable : AnimalHistory.History -> Html Msg
historyTable history =
  table [class "table is-striped is-narrow"]
    [ thead []
        [ tr []
           [ th [] [text "Effective date"]
           , th [] [text "Name"]
           , th [] [text "New tags"]
           , th [] [text "Removed tags"]
           , th [] [text "Audit Trail"]
           ]
        ]
    , tbody []
        (List.map historyRow history.entries)
    ]

historyRow : AnimalHistory.Entry -> Html Msg
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
      
    
updateWarning : Html Msg
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
    
