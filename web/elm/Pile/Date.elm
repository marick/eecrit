module Pile.Date exposing (..)

import Date exposing (Date)
import Date.Extra as Date


humane : Date -> String 
humane date =
  Date.toFormattedString "MMM d, y" date

terse : Date -> String 
terse date =     
  Date.toFormattedString "MMM d" date
    
logical : Date -> String 
logical date =
  Date.toFormattedString "yyyy-MM-dd" date
