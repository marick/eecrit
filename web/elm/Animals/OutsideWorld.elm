module Animals.OutsideWorld exposing
  ( fetchAnimals
  , askTodaysDate
  )

import Animals.Animal.Types exposing (PersistentAnimal)
import Animals.Lenses exposing (..)
import Animals.Msg exposing (..)
import Date
import Dict
import Task

askTodaysDate =
  Task.perform (always (SetToday Nothing)) (SetToday << Just) Date.now

fetchAnimals =
  Task.perform (always (SetAnimals [])) SetAnimals
    (Task.succeed [])

