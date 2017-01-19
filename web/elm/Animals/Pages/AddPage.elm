module Animals.Pages.AddPage exposing (view)

import Animals.Pages.Common as Common
import Animals.View.PageFlash as PageFlash

import Animals.Model exposing (Model)
import Animals.Msg exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.HtmlShorthand exposing (..)
import Pile.Css.Bulma as Css
import Pile.ConstrainedStrings exposing (..)

view : Model -> Html Msg
view model =
  div []
    [ startFormView model 
    , PageFlash.show model.pageFlash
    , Css.headerlessTable <| animalViews model
    ]

startFormView : Model -> Html Msg
startFormView model =
  Css.centeredColumns
    [ Css.column 11
        [ Css.messageView
            [ text "Start here"
            , startHelp Css.rightIcon
            ]
            [ Css.distributeHorizontally
                [ speciesView model
                , countView model
                , populateButton model
                ]
            ]
        ]
    ]

speciesView : Model -> Html Msg
speciesView model =
  let
    textOption val display = 
      option
      [ value val
      , Events.onClick <| withArg SetAddedSpecies val
      ]
      [ text display ]
  in
    Css.centeredLevelItem
      [ Css.headingP "Species?" 
      , Css.simpleSelect
        [ textOption "bovine" "bovine"
        , textOption "equine" "equine"
        ]
      ]
      


        
countView : Model -> Html Msg
countView model =
  Css.centeredLevelItem
    [ Css.headingP "How many?"
    , Css.simpleTextInput model.numberToAdd <| withArg UpdateAddedCount
    ]

populateButton : Model -> Html Msg
populateButton model =
  let
    onClick =
      OnAddPage <| 
        AddFormsForBlankTemplate
        (certainlyValidInt model.numberToAdd 0)
        (model.speciesToAdd)
  in
    Css.centeredLevelItem
      [ Css.headingP " "
      , a [ class "button is-primary"
          , href "#"
          , onClickPreventingDefault onClick
          ]
          [text "Click to add more information"]
      ]
         
  -- nav [class "level is-mobile"]
  --   [ div [class "level-left" ]
  --       [ p [class "level-item"]
  --           [ text "Create" ]
  --       , p [class "level-item"]
  --         [ input [ class "input", type_ "text", value "1"
  --                 , disabled True
  --                 , style [("width", "3em")]
  --                 ] []
  --         ]
  --       , p [class "level-item"]
  --         [ text "new" ]
  --       , p [class "level-item"]
  --         [ Css.disabledSelect
  --             [ option [value "bovine"] [ text "bovine" ]
  --             , option [value "equine"] [ text "equine" ]
  --             ]
  --         ]
  --       , p [class "level-item"]
  --         [ text "animal to edit" ]
  --       , p [class "level-item"]
  --         [ 
  --       ]
--    ]
    
animalViews : Model -> List (Html Msg)    
animalViews model =
  let
    displayedAnimals = Common.pageAnimals .addPageAnimals model
    animalViewer = Common.individualAnimalView model (StartCreating, CancelCreation)
  in
    displayedAnimals
      |> List.map animalViewer


startHelp : Css.IconExpander Msg -> Html Msg
startHelp iconType = 
  iconType "fa-question-circle" "Help for this form" NoOp    

         
-- Util
    
withArg : (opArg -> AddPageOperation) -> opArg -> Msg
withArg opArg = 
  opArg >> OnAddPage

withoutArg : AddPageOperation -> Msg
withoutArg = OnAddPage
  
