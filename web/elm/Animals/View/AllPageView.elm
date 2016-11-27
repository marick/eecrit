module Animals.View.AllPageView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.HtmlShorthand exposing (..)
import Html.Events as Events
import Pile.Bulma as Bulma
import String
import List
import Animals.Main exposing (DisplayState(..), Msg(..), desiredAnimals)

view model =
  div []
    [ div [class "columns is-centered"]
        [ div [class "column is-3"]
            [ messageView model "Effective Date"
                [
                  centeredLevelItem
                    [ headingP "Click to change"
                    , textInput "19-feb-1960" SetNameFilter
                    ]
                ]
            ]
        , div [class "column is-8"]
            [ messageView model "Filter by..." (filterFields model) ]
        ]
    , animalList model 
    ]

animalList model = 
  table [class "table"]
    [ tbody []
        (List.map oneAnimal (desiredAnimals model))
    ]

oneAnimal animal =
  case animal.displayState of
    Compact -> oneAnimalCompact animal
    Expanded -> oneAnimalExpanded animal
    Editable -> oneAnimalEditable animal

animalSalutation animal =
  text <| animal.name ++ " (" ++ animal.species ++ ")"

animalTags animal =
  List.map oneTag animal.tags
                
oneAnimalCompact animal = 
    tr []
      [ (td [] [ p [] ( animalSalutation animal  :: animalTags animal)])
      , expand animal
      , edit animal
      , moreLikeThis animal
      ]

oneAnimalExpanded animal =
    tr [ style [ ("border-top", "2px solid")
               , ("border-bottom", "2px solid")
               ]
       ]
      [ td []
          [ p [] [ animalSalutation animal ]
          , p [] (animalTags animal)
          , p [] [text <| "Added " ++ animal.dateAcquired]
          ]
      , contract animal
      , edit animal
      , moreLikeThis animal
      ]
      

oneAnimalEditable animal =
  tr [] [ text "editable" ] 

oneIcon iconSymbolName tooltip msg =
  td [class "is-icon"]
    [a [ href "#"
       , title tooltip
       , onClickWithoutPropagation msg
       ]
       [i [class ("fa " ++ iconSymbolName)] []]
    ]

expand animal =
  oneIcon "fa-caret-down"
    "Expand: show more about this animal"
    (ExpandAnimal animal.id)
      
contract animal =
  oneIcon "fa-caret-up"
    "Expand: show less about this animal"
    (ContractAnimal animal.id)
      
edit animal =
  oneIcon "fa-pencil"
    "Edit: make changes to this animal"
    (EditAnimal animal.id)
      
moreLikeThis animal =
  oneIcon "fa-plus"
    "Copy: make more animals like this one"
    (MoreLikeThisAnimal animal.id)
      
oneTag tagText =
  span [ class "tag" ] [ text tagText ]
    
messageView model headerText content=
  article [class "message"]
    [ div [class "message-header has-text-centered"]
        [ text headerText
        ]
    , div [class "message-body"]
      [ div [class "level"]
          content
      ]
    ]

filterFields model =
  [ nameField model
  , speciesField model
  , tagsField model 
  ]


nameField model =
  centeredLevelItem
    [ headingP "Name"
    , textInput model.nameFilter SetNameFilter
    ]

tagsField model =
  centeredLevelItem
  [ headingP "Tag"
  , textInput model.tagFilter SetTagFilter
  ]

speciesField model =
  centeredLevelItem
  [ p [class "heading"] [ text "Species" ]
  , standardSelect
      [ textOption "" "Any"
      , textOption "bovine" "bovine"
      , textOption "equine" "equine"
      ]
  ]

centeredLevelItem content =
  div [class "level-item has-text-centered"]
    content

standardSelect content = 
  span [ class "select" ]
    [ select [] content ]

textOption val display = 
  option
    [ value val
    , Events.onClick (SetSpeciesFilter val)
    ]
    [ text display ]

headingP heading = 
  p [class "heading"] [text heading]

textInput val msg = 
  p [class "control"]
    [input
       [ class "input"
       , type' "text"
       , value val
       , Events.onInput msg]
       []
    ]
