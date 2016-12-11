module Animals.Animal.CompactView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import Pile.Bulma as Bulma 
import Pile.HtmlShorthand exposing (..)

import Animals.Msg exposing (..)

import Animals.Animal.Crud exposing (..)
import Animals.Animal.Icons as Icon

view animal flash =
  tr []
    [ (td []
         [ p [] ( animalSalutation animal  :: animalTags animal)
         , showFlash flash (UpsertCompactAnimal animal)
         ])
    , Icon.expand animal Bulma.tdIcon
    , Icon.edit animal Bulma.tdIcon
    , Icon.moreLikeThis animal Bulma.tdIcon
    ]

