module Animals.Animal.ExpandedView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import Pile.Bulma as Bulma 
import Pile.HtmlShorthand exposing (..)

import Animals.Animal.Model exposing (..)
import Animals.Msg exposing (..)

import Animals.Animal.ViewUtil exposing (..)
import Animals.Animal.Icons as Icon
import Animals.Animal.Flash as Flash


view animal flash =
  Bulma.highlightedRow []
    [ td []
        [ p [] [ animalSalutation animal ]
        , p [] (animalTags animal)
        , animalProperties animal |> Bulma.propertyTable
        , Flash.showAndCancel flash (UpsertExpandedAnimal animal)
        ]
    , Icon.contract animal Bulma.tdIcon
    , Icon.edit animal Bulma.tdIcon
    , Icon.moreLikeThis animal Bulma.tdIcon
    ]
