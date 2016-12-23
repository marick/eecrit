module Animals.Animal.Constructors exposing (..)

import Dict exposing (Dict)

import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Flash exposing (AnimalFlash(..))
import Animals.Pages.Declare exposing (PageChoice(..))

compact animal =
  DisplayedAnimal animal (Display AllPage Compact NoFlash)
expanded animal =
  DisplayedAnimal animal (Display AllPage Expanded NoFlash)
editable animal form =
  DisplayedAnimal animal (Display AllPage (Editable form) NoFlash)
empty animal form = 
  DisplayedAnimal animal (Display AddPage (Editable form) NoFlash)

andFlash : AnimalFlash -> DisplayedAnimal -> DisplayedAnimal    
andFlash flash animal =
  displayedAnimal_flash.set flash animal

fresh : String -> Id -> Animal    
fresh species id =
  { id = id
  , version = 0
  , wasEverSaved = False
  , name = ""
  , species = species
  , tags = []
  , properties = Dict.empty
  }
