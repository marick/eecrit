module Animals.View.AnimalView exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import List
import String
import String.Extra as String

import Pile.Bulma as Bulma 
import Pile.HtmlShorthand exposing (..)

import Animals.Types exposing (..)
import Animals.Lenses exposing (..)
import Animals.Msg exposing (..)

view animal =
  p [] []


-- Various icons

expand animal iconType =
  iconType "fa-caret-down"
    "Expand: show more about this animal"
    (ExpandAnimal animal.id)
      
contract animal iconType =
  iconType "fa-caret-up"
    "Expand: show less about this animal"
    (ContractAnimal animal.id)
      
edit animal iconType =
  iconType "fa-pencil"
    "Edit: make changes to this animal"
    (EditAnimal animal.id)
      
moreLikeThis animal iconType =
  iconType "fa-plus"
    "Copy: make more animals like this one"
    (MoreLikeThisAnimal animal.id)
