module IV.Navigation exposing (..)

import Navigation
import UrlParser
import String

type PageChoice 
  = MainPage
  | AboutPage

-- TODO: This is unidiomatic?
program = Navigation.program
    
stringParser : String -> PageChoice
stringParser path =
  if String.contains "about" path then
    AboutPage
  else
    MainPage

locationParser : Navigation.Location -> PageChoice
locationParser location = 
  stringParser location.pathname

urlParser = Navigation.makeParser locationParser


urlUpdate page model =
  ( { model | page = page }
  , Cmd.none
  )
