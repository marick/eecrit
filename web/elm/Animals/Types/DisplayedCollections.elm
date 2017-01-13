module Animals.Types.DisplayedCollections exposing (..)

import Animals.Types.Lenses exposing (..)

import Set exposing (Set)
import List
import List.Extra as List
import Dict exposing (Dict)

dict displayables =
  let
    ids = List.map displayed_id.get displayables
  in
    List.map2 (,) ids displayables |> Dict.fromList

idSet displayables =
  List.map displayed_id.get displayables |> Set.fromList 

add displayables existingDict =
  displayables |> dict |> Dict.union existingDict
    
addReferences displayables existingSet =
  displayables |> idSet |> Set.union existingSet
    
             
    
