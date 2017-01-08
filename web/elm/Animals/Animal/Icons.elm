module Animals.Animal.Icons exposing (..)

import Html exposing (Html)
import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)
import Pile.Bulma exposing (IconExpander)

expand : DisplayedAnimal -> IconExpander Msg -> Html Msg
expand displayed iconType =
  iconType "fa-caret-down"
    "Expand: show more about this animal"
    (WithAnimal displayed <| SwitchToReadOnly Expanded)

contract : DisplayedAnimal -> IconExpander Msg -> Html Msg
contract displayed iconType =
  iconType "fa-caret-up"
    "Contract: show less about this animal"
    (WithAnimal displayed <| SwitchToReadOnly Compact)
      
edit : DisplayedAnimal -> IconExpander Msg -> Html Msg
edit displayed iconType =
  iconType "fa-pencil"
    "Edit: make changes to this animal"
    (WithAnimal displayed StartEditing)
      
moreLikeThis : DisplayedAnimal -> IconExpander Msg -> Html Msg
moreLikeThis displayed iconType =
  iconType "fa-plus"
    "Copy: make more animals like this one"
    (WithAnimal displayed MoreLikeThis)

editHelp : IconExpander Msg -> Html Msg
editHelp iconType = 
  iconType "fa-question-circle" "Help on editing" NoOp    
