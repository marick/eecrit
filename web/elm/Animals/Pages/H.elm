
-- Files containing nothing but declarations (typically to avoid circular
-- dependencies) rejoice in the conventional name `H.elm`, which should remind
-- you of C's include files.
--
-- Whimsy is allowed.

module Animals.Pages.H exposing (..)

import Animals.Types.Basic exposing (..)

type PageChoice 
  = AllPage
  | AddPage
  | HelpPage
  | HistoryPage Id


