module Animals.Animal.Icons exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events

import Pile.HtmlShorthand exposing (..)

import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)
-- import Animals.Animal.Form as Form
import Animals.Animal.Flash as Flash

expand displayed iconType =
  iconType "fa-caret-down"
    "Expand: show more about this animal"
    (WithAnimal displayed <| SwitchToReadOnly Expanded)
      
contract displayed iconType =
  iconType "fa-caret-up"
    "Contract: show less about this animal"
    (WithAnimal displayed <| SwitchToReadOnly Compact)
      
edit displayed iconType =
  iconType "fa-pencil"
    "Edit: make changes to this animal"
    (WithAnimal displayed StartEditing)
      
moreLikeThis animal iconType =
  iconType "fa-plus"
    "Copy: make more animals like this one"
    (WithAnimal animal MoreLikeThis)

editHelp iconType = 
  iconType "fa-question-circle" "Help on editing" NoOp    
      
