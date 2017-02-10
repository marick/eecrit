module Pile.Date exposing (..)

import Date.Extra as Date


humane date =
  Date.toFormattedString "MMM d, y" date

terse date =     
  Date.toFormattedString "MMM d" date
    
logical date =
  Date.toFormattedString "yyyy-MM-dd" date
