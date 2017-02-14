module Animals.Pages.Navigation exposing
  ( fromLocation
  , gotoMsg
  , toPageChangeCmd
  )

import Animals.Msg exposing (..)
import Animals.Pages.H exposing (..)

import Navigation
import String
import Maybe.Extra as Maybe

defaultPath : String
defaultPath = "/v2/animals"

defaultPage : PageChoice
defaultPage = AllPage

constants : List ( String, PageChoice )
constants =
  [ (defaultPath, defaultPage)
  ]

-- So annoying you can't use type values as Dict keys

convertPath : String -> Maybe PageChoice
convertPath from =
  case from of
    "/v2/animals" -> Just AllPage
    "/v2/animals/new" -> Just AddPage
    "/v2/animals/help" -> Just HelpPage
    _ -> Nothing
                     
convertChoice : PageChoice -> Maybe String
convertChoice from =
  case from of
    AllPage -> Just "/v2/animals"
    AddPage -> Just "/v2/animals/new"
    HelpPage -> Just "/v2/animals/help"
    _ -> Nothing

parsePath : String -> Maybe PageChoice
parsePath from =
  case String.split "/" from of
    ["", "v2", "animals", id, "history"] ->
      Just <| HistoryPage id
    _ ->
      Nothing

unparseChoice : PageChoice -> Maybe String
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
        
