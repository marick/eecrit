module C4u.Navigation exposing (..)

import Navigation
import UrlParser
import String

type PageChoice 
  = MainPage

-- TODO: This is unidiomatic?
programWithFlags = Navigation.programWithFlags
    
stringParser : String -> PageChoice
stringParser path =
  MainPage

locationParser : Navigation.Location -> PageChoice
locationParser location = 
  stringParser location.pathname

urlParser = Navigation.makeParser locationParser


urlUpdate page model =
  ( { model | page = page }
  , Cmd.none
  )
