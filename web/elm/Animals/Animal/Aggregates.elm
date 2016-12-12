module Animals.Animal.Aggregates exposing
  (
  ..
  )

import Dict exposing (Dict)
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

asAggregate animals =
  let
    tuple animal = (animal.id, DisplayedAnimal animal Compact NoFlash)
  in
    animals |> List.map tuple |> Dict.fromList

