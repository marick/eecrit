module Animals.View.Icons exposing (..)

import Animals.Msg exposing (..)
import Animals.Types.Basic exposing (..)
import Animals.Types.Animal as Animal exposing (Animal)

import Pile.Css.Bulma as Css
import Html exposing (Html)

expand : Animal -> Css.IconExpander Msg -> Html Msg
expand animal iconType =
  iconType "fa-caret-down"
    "Expand: show more about this animal"
    (WithAnimal animal <| SwitchToReadOnly Animal.Expanded)

contract : Animal -> Css.IconExpander Msg -> Html Msg
contract animal iconType =
  iconType "fa-caret-up"
    "Contract: show less about this animal"
    (WithAnimal animal <| SwitchToReadOnly Animal.Compact)
      
edit : Animal -> Css.IconExpander Msg -> Html Msg
edit animal iconType =
  iconType "fa-pencil"
    "Edit: make changes to this animal"
    (WithAnimal animal StartEditing)
      
moreLikeThis : Id -> Css.IconExpander Msg -> Html Msg
moreLikeThis id iconType =
  iconType "fa-plus"
    "Copy: make more animals like this one"
    (WithDisplayedId id BeginGatheringCopyInfo)

editHelp : Css.IconExpander Msg -> Html Msg
editHelp iconType = 
  iconType "fa-question-circle" "Help on editing" NoOp    
