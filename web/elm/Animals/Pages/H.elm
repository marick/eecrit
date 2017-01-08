
-- Files containing nothing but declarations (typically to avoid circular
-- dependencies) rejoice in the conventional name `H.elm`, which should remind
-- you of C's include files.
--
-- Whimsy is allowed.

module Animals.Pages.H exposing (..)

-- Declare and Define are separate because of circular dependencies.

type PageChoice 
  = AllPage
  | AddPage
  | HelpPage

allPagePath : String
allPagePath = "/v2/animals"

addPagePath : String
addPagePath = "/v2/animals/new"

helpPagePath : String
helpPagePath = "/v2/animals/help"


