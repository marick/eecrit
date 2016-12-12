module Animals.Animal.CompactView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import Pile.Bulma as Bulma 
import Pile.HtmlShorthand exposing (..)

import Animals.Msg exposing (..)

import Animals.Animal.ViewUtil exposing (..)
import Animals.Animal.Icons as Icon
import Animals.Animal.Flash as Flash

view animal flash =
  tr []
    [ (td []
         [ p [] ( animalSalutation animal  :: animalTags animal)
         , Flash.showAndCancel flash (UpsertCompactAnimal animal)
         ])
    , Icon.expand animal Bulma.tdIcon
    , Icon.edit animal Bulma.tdIcon
    , Icon.moreLikeThis animal Bulma.tdIcon
    ]

