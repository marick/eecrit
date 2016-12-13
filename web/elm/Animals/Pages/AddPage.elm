module Animals.Pages.AddPage exposing (..)

import Animals.Pages.AllPage as Common

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.Bulma as Bulma
import String
import Dict
import Set

import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Msg exposing (..)
import Animals.Animal.EditableView as RW
import Animals.Animal.Validation exposing (ValidationContext)

view model =
  let
    validationContext = Common.calculateValidationContext model
    whichToShow =
      model.newAnimals
        |> Dict.values
        |> Common.humanSorted
        |> Common.contextualize validationContext
  in
    div []
      [ Bulma.headerlessTable whichToShow
      ]
