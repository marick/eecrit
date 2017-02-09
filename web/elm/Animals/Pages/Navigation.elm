module Animals.Pages.Navigation exposing
  ( fromLocation
  , gotoMsg
  , toPageChangeCmd
  )

import Animals.Msg exposing (..)
import Animals.Pages.H exposing (..)

import Navigation
import String

gotoMsg : PageChoice -> Msg
gotoMsg choice = 
  Navigate <| StartChange choice

toPageChangeCmd : PageChoice -> Cmd Msg
toPageChangeCmd page =
  let
    url =
      case page of
        AllPage -> allPagePath
        AddPage -> addPagePath
        HelpPage -> helpPagePath
        _ -> "TBD"
  in
    Navigation.newUrl url

fromLocation : Navigation.Location -> PageChoice
fromLocation location =
  let
    path = location.pathname
  in
    if String.startsWith addPagePath path then 
      AddPage
    else if String.startsWith helpPagePath path then 
      HelpPage
    else
      AllPage

        
