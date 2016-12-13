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
      model.animals
        |> Dict.values
        |> Common.humanSorted
        |> Common.contextualize validationContext
  in
    div []
      [ nav [class "level is-mobile"]
          [ div [class "level-left" ]
              [ div [class "level-item"]
                  [ text "Create" ]
              , div [class "level-item"]
                [ input [ class "input", type' "text", value "1"
                        , style [("width", "3em")]
                        ] []
                ]
              , div [class "level-item"]
                [ text "new" ]
              , div [class "level-item"]
                [ Bulma.simpleSelect
                    [ option [value "bovine"] [ text "bovine" ]
                    , option [value "equine"] [ text "equine" ]
                    ]
                ]
              , div [class "level-item"]
                [ text "animal to edit" ]
              , div [class "level-item"]
                [ a [ class "button is-primary" ] [text "Now"]]
              ]

          ]
      , Bulma.headerlessTable whichToShow
      ]
