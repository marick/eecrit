module Animals.Pages.Navigation exposing
  ( fromLocation
  , gotoMsg
  , toPageChangeCmd
  )

import Animals.Msg exposing (..)
import Animals.Pages.H exposing (..)

import Navigation
import String
import Dict
import Maybe.Extra as Maybe
import Tuple

defaultPath = "/v2/animals"
defaultPage = AllPage

constants =
  [ (defaultPath, defaultPage)
  ]

-- So annoying you can't use type values as Dict keys

convertPath from =
  case from of
    "/v2/animals" -> Just AllPage
    "/v2/animals/new" -> Just AddPage
    "/v2/animals/help" -> Just HelpPage
    _ -> Nothing
                     
convertChoice from =
  case from of
    AllPage -> Just "/v2/animals"
    AddPage -> Just "/v2/animals/new"
    HelpPage -> Just "/v2/animals/help"
    _ -> Nothing

parsePath from =
  case String.split "/" from of
    ["", "v2", "animals", id, "history"] ->
      Just <| HistoryPage id
    _ ->
      Nothing

unparseChoice choice =
  case choice of
    HistoryPage id ->
      Just <| "/" ++ String.join "/" ["v2", "animals", id, "history"]
    _ ->
      Nothing

gotoMsg : PageChoice -> Msg
gotoMsg choice = 
  Navigate <| StartChange choice

toPageChangeCmd : PageChoice -> Cmd Msg
toPageChangeCmd choice =
  let
    url =
      convertChoice choice
        |> Maybe.orElse (unparseChoice choice)
        |> Maybe.withDefault defaultPath
  in
    Navigation.newUrl url
      
fromLocation : Navigation.Location -> PageChoice
fromLocation location =
  let
    path = location.pathname
  in
    convertPath (Debug.log "path" path)
      |> Maybe.orElse (parsePath path)
      |> Maybe.withDefault defaultPage
        
