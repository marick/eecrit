module Animals.Pages.AddPage exposing (view)

import Animals.Pages.Common as Common
import Animals.Pages.PageFlash as PageFlash

import Animals.Model exposing (Model)
import Animals.Msg exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.HtmlShorthand exposing (..)
import Pile.Css.Bulma as Css

view : Model -> Html Msg
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
              [ Css.disabledSelect
                  [ option [value "bovine"] [ text "bovine" ]
                  , option [value "equine"] [ text "equine" ]
                  ]
              ]
            , p [class "level-item"]
              [ text "animal to edit" ]
            , p [class "level-item"]
              [ a [ class "button is-primary"
                  , href "#"
                  , onClickPreventingDefault <| AddNewAnimals 1 "bovine"
                  ]
                  [text "Now"]]
            ]
        ]
    , PageFlash.show model.pageFlash
    , Css.headerlessTable <| animalViews model
    ]

animalViews : Model -> List (Html Msg)    
animalViews model =
  let
    displayedAnimals = Common.pageAnimals .addPageAnimals model
    animalViewer = Common.individualAnimalView model (StartCreating, CancelCreation)
  in
    displayedAnimals
      |> List.map animalViewer
