module Animals.View.AllPageView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.HtmlShorthand exposing (..)
import Html.Events as Events
import Pile.Bulma as Bulma
import String
import List
import Animals.Main exposing (DisplayState(..), Msg(..))

view model =
  div []
    [ filterMessage model (filterFields model)
    , animalList model 
    ]

animalList model = 
  table [class "table"]
    [ tbody []
        (List.map oneAnimal model.animals)
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
    
filterMessage model content=
  div [class "columns is-centered"]
    [ div [class "column is-10"]
        [ article [class "message"]
            [ div [class "message-header has-text-centered"]
               [ text "Filter by..."
               ]
            , div [class "message-body"]
                [ div [class "level"]
                    content
                ]
            ]
        ]
    ]


    

filterFields model =
  [ nameField model
  , speciesField model
  , tagsField model 
  ]


nameField model =
  centeredLevelItem [ headingP "Name", textInput ]

tagsField model =
  centeredLevelItem [ headingP "Tag", textInput ]
  

speciesField model =
  centeredLevelItem
  [ p [class "heading"] [ text "Species" ]
  , standardSelect
      [ defaultOption "Choose"
      , textOption "bovine"
      , textOption "equine"
      ]
  ]

centeredLevelItem content =
  div [class "level-item has-text-centered"]
    content

standardSelect content = 
  span [ class "select" ]
    [ select [] content ]

textOption val = 
  option [ value val ] [ text val ]

defaultOption name =
  option [value ""] [ text name ] 


headingP heading = 
  p [class "heading"] [text heading]

textInput = 
  p [class "control"]
    [input [class "input", type' "text", value ""] []]
