module Animals.Pages.Navigation exposing
  ( fromLocation
  , toPageChangeCmd
  )

import Animals.Pages.H exposing (..)
import Animals.Msg exposing (..)
import Navigation
import String

toPageChangeCmd : PageChoice -> Cmd Msg
toPageChangeCmd page =
  let
    url =
      case page of
        AllPage -> allPagePath
        AddPage -> addPagePath
        HelpPage -> helpPagePath
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
