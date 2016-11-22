module Animals.Navigation exposing (..)

import Navigation
import UrlParser
import String

type PageChoice 
  = AllAnimalsPage

-- TODO: This is unidiomatic?
programWithFlags = Navigation.programWithFlags
    
stringParser : String -> PageChoice
stringParser path =
  AllAnimalsPage

desireToPage : String -> PageChoice
desireToPage desire =
  case desire of
    "ViewAllInUseAnimals" -> AllAnimalsPage
    _ -> AllAnimalsPage
    

locationParser : Navigation.Location -> PageChoice
locationParser location = 
  stringParser location.pathname

urlParser = Navigation.makeParser locationParser


urlUpdate page model =
  ( { model | page = page }
  , Cmd.none
  )
