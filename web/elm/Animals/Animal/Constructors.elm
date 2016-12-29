module Animals.Animal.Constructors exposing (..)

import Dict exposing (Dict)

import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Flash exposing (AnimalFlash(..))

compact animal = DisplayedAnimal animal Compact NoFlash
expanded animal = DisplayedAnimal animal Expanded NoFlash
editable animal = DisplayedAnimal animal Editable NoFlash
  
andFlash : AnimalFlash -> DisplayedAnimal -> DisplayedAnimal    
andFlash flash animal =
  displayedAnimal_flash.set flash animal

noFlash : DisplayedAnimal -> DisplayedAnimal
noFlash = andFlash NoFlash
    
fresh : String -> Id -> Animal    
fresh species id =
  { id = id
  , version = 0
  , name = ""
  , species = species
  , tags = []
  , properties = Dict.empty
  }
