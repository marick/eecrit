module Animals.View.AllPageView exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pile.Bulma as Bulma
import String
import List

view model =
  div []
    [ filterMessage model (filterFields model)
    , animalList model 
    ]

animalList model = 
  div []
    (List.map oneAnimal model.animals)

oneAnimal animal =
  let
    animalText = text <| animal.name ++ " (" ++ animal.species ++ ")"
    animalTags = List.map oneTag animal.tags

  in
    div [class "card is-fullwidth"]
      [ header [class "card-header"]
          [ p [class "card-header-title"]
              ( animalText :: animalTags)
          , oneIcon "fa-caret-down"
          , oneIcon "fa-pencil"
          , oneIcon "fa-plus"
          , oneIcon "fa-trash"
          ]
      ]

oneIcon iconSymbolName =
  a [class "card-header-icon"]
    [span [class "icon"]
       [i [class ("fa " ++ iconSymbolName)] []]
    ]

      
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
