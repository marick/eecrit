module Animals.Pages.AddPage exposing (..)

import Animals.Pages.AllPage as Common

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.HtmlShorthand exposing (..)
import Pile.Bulma as Bulma
import String
import Dict
import Set

import Animals.Pages.PageFlash as PageFlash
import Animals.Animal.Types exposing (..)
import Animals.Animal.Lenses exposing (..)
import Animals.Msg exposing (..)
import Animals.Animal.EditableView as RW
import Animals.Animal.Validation exposing (ValidationContext)

view model =
  let
    validationContext = Common.calculateValidationContext model
    whichToShow = filteredAnimals model |> Common.contextualize validationContext
  in
    div []
      [ nav [class "level is-mobile"]
          [ div [class "level-left" ]
              [ p [class "level-item"]
                  [ text "Create" ]
              , p [class "level-item"]
                  [ input [ class "input", type_ "text", value "1"
                          , style [("width", "3em")]
                          ] []
                  ]
              , p [class "level-item"]
                  [ text "new" ]
              , p [class "level-item"]
                  [ Bulma.simpleSelect
                      [ option [value "bovine"] [ text "bovine" ]
                      , option [value "equine"] [ text "equine" ]
                      ]
                  ]
              , p [class "level-item"]
                  [ text "animal to edit" ]
              , p [class "level-item"]
                  [ a [ class "button is-primary"
                      , href "#"
                      , onClickWithoutPropagation AddNewBovine
                      ]
                      [text "Now"]]
              ]
          ]
      , PageFlash.show model.pageFlash
      , Bulma.headerlessTable whichToShow
      ]


filteredAnimals model =
  Common.animalsToDisplay model [not << displayedAnimal_wasEverSaved.get]
