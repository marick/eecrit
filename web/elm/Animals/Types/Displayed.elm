module Animals.Types.Displayed exposing (..)

import Animals.Types.Animal exposing (Animal)
import Animals.Types.Form exposing (Form)
import Animals.View.AnimalFlash as AnimalFlash exposing (AnimalFlash(..))

import Set exposing (Set)
import List
import List.Extra as List
import Dict exposing (Dict)

type alias Displayed =
  { view : Affordance
  , animalFlash : AnimalFlash
  }

type Affordance
  = Writable Form
  | Viewable Animal

    
fromForm : Form -> Displayed
fromForm form =
  Displayed (Writable form) NoFlash

fromAnimal : Animal -> Displayed
fromAnimal animal =
  Displayed (Viewable animal) NoFlash

