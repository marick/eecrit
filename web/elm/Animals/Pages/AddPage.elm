module Animals.Pages.AddPage exposing (view)

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

view model =
  div []
    [ nav [class "level is-mobile"]
        [ div [class "level-left" ]
            [ p [class "level-item"]
                [ text "Create" ]
            , p [class "level-item"]
              [ input [ class "input", type_ "text", value "1"
                      , disabled True
                      , style [("width", "3em")]
                      ] []
              ]
            , p [class "level-item"]
              [ text "new" ]
            , p [class "level-item"]
              [ Bulma.disabledSelect
                  [ option [value "bovine"] [ text "bovine" ]
                  , option [value "equine"] [ text "equine" ]
                  ]
              ]
            , p [class "level-item"]
              [ text "animal to edit" ]
            , p [class "level-item"]
              [ a [ class "button is-primary"
                  , href "#"
                  , onClickWithoutPropagation <| AddNewAnimals 1 "bovine"
                  ]
                  [text "Now"]]
            ]
        ]
    , PageFlash.show model.pageFlash
    , Bulma.headerlessTable <| animalViews model
    ]

animalViews model =
  let
    displayedAnimals = Common.pageAnimals .addPageAnimals model
    animalViewer = Common.individualAnimalView model (StartCreating, CancelCreation)
  in
    displayedAnimals
      |> List.map animalViewer
