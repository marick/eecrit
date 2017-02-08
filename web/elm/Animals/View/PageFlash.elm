module Animals.View.PageFlash exposing (..)

import Animals.Msg exposing (Msg(..))
import Animals.Pages.H exposing (PageChoice(..))
import Animals.Pages.Navigation as Navigation

import Pile.Css.Bulma as Css
import Pile.HtmlShorthand exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http

type PageFlash
  = NoFlash
  | SavedAnimalFlash
  | SavedAnimalWillNotAppearFlash
  | HttpErrorFlash String Http.Error

show : PageFlash -> Html Msg
show flash =
  case flash of 
    NoFlash -> 
      span [] []
    SavedAnimalFlash -> 
      Css.flashNotification NoOp
        [ text "The new animal can be seen on the "
        , a [ href "#"
            , onClickPreventingDefault <| Navigation.gotoMsg AllPage
            ]
            [text "View Animals"]
        , text " page."
        ]

    SavedAnimalWillNotAppearFlash ->
      Css.flashNotification NoOp
        [ text """ The new animal is being saved.
                Because the creation date is later than the date on the 
                """
        , a [ href "#"
            , onClickPreventingDefault <| Navigation.gotoMsg AllPage
            ]
            [text "View Animals"]
        , text """ page, you won't see it there (unless you advance the
                date on that page). 
               """
        ]
      

    HttpErrorFlash contextString err ->
      httpError contextString err

httpError : String -> Http.Error -> Html Msg
httpError contextString err =
  let
    errText =
      case err of
          Http.BadUrl s ->
            [ text "Something is wrong with this app. It created a bad web address"
            , p [] [text "Details: ", text s]
            ]
            
          Http.Timeout ->
            [ text "The server did not respond. Try again later?" ]
                
          Http.NetworkError ->
            [ text "The problem was that I could not reach critter4us.com. My best guess is there's a problem with your connection to the internet." ]
                    
          Http.BadStatus {status} ->
            [ text "The server declared that it could not respond."
            , p [] [text "Details: ", text status.message]
            ]
                              
          Http.BadPayload s response ->
            [ text "The server returned nonsensical results."
            , p [] [text "Details: ", text s]
            ]
    paddedContext =
      contextString ++ " "
  in
    Css.flashNotification NoOp
      (text paddedContext :: errText)
