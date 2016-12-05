module Animals.OutsideWorld exposing
  ( fetchAnimals
  , askTodaysDate
  )

import Animals.Types exposing (..)
import Animals.Msg exposing (..)
import Date
import Dict
import Task


