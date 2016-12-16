module Animals.Pages.Declare exposing (..)

-- Declare and Define are separate because of circular dependencies.

type PageChoice 
  = AllPage
  | AddPage
  | HelpPage

allPagePath = "/v2/animals"
addPagePath = "/v2/animals/new"
helpPagePath = "/v2/animals/help"


