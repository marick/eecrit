module Animals.Lenses exposing (..)

import Animals.Types exposing (..)
import Monocle.Lens exposing (..)
import List.Extra as List


model_page : Lens { m | page : whole } whole
model_page =
  let
    get arg1 = arg1.page
    set new2 arg1 = { arg1 | page = new2 }
  in
    Lens get set

model_animals : Lens { m | animals : whole } whole
model_animals =
  let
    get arg1 = arg1.animals
    set new2 arg1 = { arg1 | animals = new2 }
  in
    Lens get set
      
-- animals_animal : id -> Optional (List animal) animal
-- model_animals id =
--   let
--     getOption id = List.find ((=) id) 
--     set new2 arg1 = { arg1 | animals = new2 }
--   in
--     Lens get set
      
