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


view {persistent, display} =
  case display of
    Compact -> compactView persistent
    Expanded -> expandedView persistent
    Editable changing -> editableView persistent changing

compactView animal =
  tr []
    [ (td [] [ p [] ( animalSalutation animal  :: animalTags animal)])
    , expand animal Bulma.tdIcon
    , edit animal Bulma.tdIcon
    , moreLikeThis animal Bulma.tdIcon
    ]
expandedView animal =
  p [] [text animal.id]
editableView animal changes =
  p [] [text animal.id]

animalSalutation animal =
  text <| (String.toSentenceCase animal.name) ++ (parentheticalSpecies animal)

animalTags animal =
  List.map Bulma.readOnlyTag animal.tags

parentheticalSpecies animal =
  " (" ++ animal.species ++ ")"


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
