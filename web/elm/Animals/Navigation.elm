module Animals.Navigation exposing (..)

import Navigation
import UrlParser
import String
import Animals.Lenses exposing (..)

type PageChoice 
  = AllPage
  | AddPage
  | HelpPage

allPagePath = "/v2/animals"
addPagePath = "/v2/animals/new"
helpPagePath = "/v2/animals/help"


goto : String -> model -> (model, Cmd msg)
goto path model =
  ( model
  , Navigation.newUrl path
  )
               
toAllPagePath = goto allPagePath
toAddPagePath = goto addPagePath
toHelpPagePath = goto helpPagePath

-- TODO: This is unidiomatic?
programWithFlags = Navigation.programWithFlags
    
stringParser : String -> PageChoice
stringParser path =
  if String.startsWith addPagePath path then 
    AddPage
  else if String.startsWith helpPagePath path then 
    HelpPage
  else
    AllPage

locationParser : Navigation.Location -> PageChoice
locationParser location = 
  stringParser location.pathname

urlParser = Navigation.makeParser locationParser

urlUpdate newPage model =
  model_page.set newPage model ! [] 
