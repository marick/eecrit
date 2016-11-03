module IV.Navigation exposing (..)

import Navigation
import UrlParser

type PageChoice 
  = MainPage
  | AboutPage

-- TODO: This is unidiomatic?
program = Navigation.program
    
stringParser : String -> PageChoice
stringParser path =
  MainPage

locationParser : Navigation.Location -> PageChoice
locationParser location = 
  stringParser location.pathname

urlParser = Navigation.makeParser locationParser


urlUpdate : PageChoice -> model -> ( model, Cmd msg )
urlUpdate url model =
    (model, Cmd.none)
