module Animals.Animal.Constructors exposing (..)

import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Animal.Flash exposing (AnimalFlash(..))

x = 44

-- compact : Animal -> DisplayedAnimal
-- compact animal = DisplayedAnimal animal Compact NoFlash

-- expanded : Animal -> DisplayedAnimal
-- expanded animal = DisplayedAnimal animal Expanded NoFlash

-- editable : Animal -> DisplayedAnimal
-- editable animal = DisplayedAnimal animal Editable NoFlash
  
-- andFlash : AnimalFlash -> DisplayedAnimal -> DisplayedAnimal    
-- andFlash flash animal =
--   displayedAnimal_flash.set flash animal

-- noFlash : DisplayedAnimal -> DisplayedAnimal
-- noFlash = andFlash NoFlash
