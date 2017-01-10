module Animals.Animal.Icons exposing (..)

import Html exposing (Html)
import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)
import Pile.Bulma exposing (IconExpander)

expand : Animal -> IconExpander Msg -> Html Msg
expand animal iconType =
  iconType "fa-caret-down"
    "Expand: show more about this animal"
    (WithAnimal animal <| SwitchToReadOnly Expanded)

contract : Animal -> IconExpander Msg -> Html Msg
contract animal iconType =
  iconType "fa-caret-up"
    "Contract: show less about this animal"
    (WithAnimal animal <| SwitchToReadOnly Compact)
      
edit : Animal -> IconExpander Msg -> Html Msg
edit animal iconType =
  iconType "fa-pencil"
    "Edit: make changes to this animal"
    (WithAnimal animal StartEditing)
      
moreLikeThis : Animal -> IconExpander Msg -> Html Msg
moreLikeThis animal iconType =
  iconType "fa-plus"
    "Copy: make more animals like this one"
    (WithAnimal animal MoreLikeThis)

editHelp : IconExpander Msg -> Html Msg
editHelp iconType = 
  iconType "fa-question-circle" "Help on editing" NoOp    
