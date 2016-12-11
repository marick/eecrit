module Animals.Animal.ExpandedView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import Pile.Bulma as Bulma 
import Pile.HtmlShorthand exposing (..)

import Animals.Animal.Model exposing (..)
import Animals.Msg exposing (..)

import Animals.Animal.Crud exposing (..)
import Animals.Animal.Icons as Icon


view animal flash =
  Bulma.highlightedRow []
    [ td []
        [ p [] [ animalSalutation animal ]
        , p [] (animalTags animal)
        , animalProperties animal |> Bulma.propertyTable
        , showFlash flash (UpsertExpandedAnimal animal)
        ]
    , Icon.contract animal Bulma.tdIcon
    , Icon.edit animal Bulma.tdIcon
    , Icon.moreLikeThis animal Bulma.tdIcon
    ]
