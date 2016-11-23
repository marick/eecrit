module Animals.Navigation exposing (..)

import Navigation
import UrlParser
import String

type PageChoice 
  = AllPage
  | AddPage
  | HelpPage

-- TODO: This is unidiomatic?
programWithFlags = Navigation.programWithFlags
    
stringParser : String -> PageChoice
stringParser path =
  AllPage

desireToPage : String -> PageChoice
desireToPage desire =
  case desire of
    "ViewAllInUseAnimals" -> AllPage
    _ -> AllPage
    

locationParser : Navigation.Location -> PageChoice
locationParser location = 
  stringParser location.pathname

urlParser = Navigation.makeParser locationParser


urlUpdate page model =
  ( { model | page = page }
  , Cmd.none
  )
