module Animals.Types.DisplayedCollections exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Lenses exposing (..)
import Animals.Types.Displayed exposing (Displayed)

import Set exposing (Set)
import List
import Dict exposing (Dict)

dict : List Displayed -> Dict Id Displayed
dict displayables =
  let
    ids = List.map displayed_id.get displayables
  in
    List.map2 (,) ids displayables |> Dict.fromList

idSet : List Displayed -> Set String
idSet displayables =
  List.map displayed_id.get displayables |> Set.fromList 

add : List Displayed -> Dict Id Displayed -> Dict Id Displayed
add displayables existingDict =
  displayables |> dict |> Dict.union existingDict
    
addReferences: List Displayed -> Set String -> Set String    
addReferences displayables existingSet =
  displayables |> idSet |> Set.union existingSet
    
removeMembers : Set Id -> Dict Id Displayed -> Dict Id Displayed
removeMembers removables displayables =
  let 
    isKeeper id _ = not <| Set.member id removables
  in
    Dict.filter isKeeper displayables
