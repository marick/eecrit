module Animals.Animal exposing (..)

import Animals.Types exposing (..)
import Animals.Lenses exposing (..)
import Animals.Msg exposing (..)
import Dict
import List
import List.Extra as List
import Maybe.Extra as Maybe

      
asDict animals =
  let
    tuple animal = (animal.id, Compact animal)
  in
    animals |> List.map tuple |> Dict.fromList
