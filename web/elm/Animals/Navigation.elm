module Animals.Navigation exposing (..)

import Navigation
import UrlParser
import String

type PageChoice 
  = AllPage
  | SpreadsheetPage
  | SummaryPage
  | AddPage
  | HelpPage

allPagePath = "/v2/animals"
spreadsheetPagePath = "/v2/animals/spreadsheet"
summaryPagePath = "/v2/animals/summary"
addPagePath = "/v2/animals/new"
helpPagePath = "/v2/animals/help"

-- TODO: This is unidiomatic?
programWithFlags = Navigation.programWithFlags
    
stringParser : String -> PageChoice
stringParser path =
  if String.startsWith addPagePath path then 
    AddPage
  else if String.startsWith spreadsheetPagePath path then 
    SpreadsheetPage
  else if String.startsWith summaryPagePath path then 
    SummaryPage
  else if String.startsWith helpPagePath path then 
    HelpPage
  else
    AllPage

locationParser : Navigation.Location -> PageChoice
locationParser location = 
  stringParser location.pathname

urlParser = Navigation.makeParser locationParser


urlUpdate page model =
  ( { model | page = page }
  , Cmd.none
  )
