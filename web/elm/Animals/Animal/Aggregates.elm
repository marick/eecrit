module Animals.Animal.Aggregates exposing
  (
  ..
  )

import Dict exposing (Dict)
import Set exposing (Set)
import String
import Animals.Animal.Types exposing (..)
import Animals.Animal.Flash exposing (..)
import Animals.Animal.Lenses exposing (..)

type alias VisibleAggregate = Dict Id DisplayedAnimal

emptyAggregate : VisibleAggregate
emptyAggregate = Dict.empty

upsert : DisplayedAnimal -> VisibleAggregate -> VisibleAggregate
upsert displayed aggregate =
  let
    key = (displayedAnimal_id.get displayed)
  in
    Dict.insert key displayed aggregate


deleteById : Id -> VisibleAggregate -> VisibleAggregate
deleteById = Dict.remove

asAggregate : List Animal -> Dict Id DisplayedAnimal             
asAggregate animals =
  let
    tuple animal = (animal.id, compact animal NoFlash)
  in
    animals |> List.map tuple |> Dict.fromList


-- Todo: As things stand **TODAY**, it's impossible to get a duplicate
-- Id. But it's probably prudent to check.
freshId aggregate =
  let
    existing = (Dict.keys aggregate)
    name i = "newbie" ++ toString i
    worker i =
      case List.member (name i) existing of
        True -> worker (1 + i)
        False -> name i
  in
    worker (Dict.size aggregate)
  
  
animalNames : VisibleAggregate -> Set String
animalNames animals =
  animals
    |> Dict.values
    |> List.map displayedAnimal_name.get
    |> Set.fromList
