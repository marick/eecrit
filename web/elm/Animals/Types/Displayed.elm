module Animals.Types.Displayed exposing (..)

import Animals.Types.Animal exposing (Animal)
import Animals.Types.Form exposing (Form)
import Animals.View.AnimalFlash as AnimalFlash exposing (AnimalFlash(..))

type alias Displayed =
  { view : Affordance
  , animalFlash : AnimalFlash
  }

type Affordance
  = Writable Form
  | Viewable Animal

    
