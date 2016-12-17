module Animals.Pages.PageFlash exposing (..)

import Html exposing (..)
import Pile.Bulma as Bulma 
import Animals.Msg exposing (Msg(..))
import Http exposing (..)

type Flash
  = NoFlash
  | SavedAnimalFlash
  | HttpErrorFlash String Http.Error

show : Flash -> Html Msg
show flash =
  case flash of 
    NoFlash -> 
      span [] []
    SavedAnimalFlash -> 
      Bulma.flashNotification NoOp
        [ text "The new animal can be seen on the All Animals page." ]

    HttpErrorFlash contextString err ->
      httpError contextString err

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
            [ text "The network seems unavailable." ]
                    
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
    Bulma.flashNotification NoOp
      (text paddedContext :: errText)
