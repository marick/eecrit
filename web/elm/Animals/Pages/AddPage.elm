module Animals.Pages.AddPage exposing (view)

import Animals.Model exposing (Model)
import Animals.Msg exposing (..)

import Animals.Pages.Common as Common
import Animals.View.PageFlash as PageFlash
import Animals.View.TextField as TextField

import Pile.Css.Bulma as Css
import Pile.ConstrainedStrings as Constrained
import Pile.Css.Bulma.TextField as TextField
import Pile.Css.Bulma.Button as Button

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events

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
  let
    onInput string
      = OnAddPage <| UpdateAddedCount string

    textField =
      model.numberToAdd
        |> TextField.editingEvents
             (Just onInput)
             TextField.NeverSubmit
        |> TextField.kind TextField.plainTextField
        |> TextField.allowOtherControlsOnLine
        |> TextField.build
  in
    Css.centeredLevelItem
      [ Css.headingP "How many?"
      , textField
      ]

populateButton : Model -> Html Msg
populateButton model =
  let
    onClick =
      OnAddPage <| 
        AddFormsForBlankTemplate
        -- Note: if the impossible happens, creating a single animal is not
        -- a bad default
        (Constrained.certainlyValidInt model.numberToAdd.value 1)
        (model.speciesToAdd)
    buttonEvent = Button.eventsFromValue model.numberToAdd onClick
  in
    Css.centeredLevelItem
      [ Css.emptyHeading
      , Button.primaryButton "Click to add more information" buttonEvent 
      ]
    
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
  
