module Animals.View.AllPageView exposing (view)



    

-- The animals



animalViewExpanded animal =
  tr [ emphasizeBorder ]
    [ td []
        [ p [] [ animalSalutation animal ]
        , p [] (animalTags animal)
        , animalProperties animal |> Bulma.propertyTable
        ]
    , contract animal Bulma.tdIcon
    , edit animal Bulma.tdIcon
    , moreLikeThis animal Bulma.tdIcon
    ]

editableName animal =
  case animal.editableCopy of
    Nothing ->
      ""
    Just editable ->
      editable.name
    
editableTags animal =
  case animal.editableCopy of
    Nothing ->
      []
    Just editable ->
      editable.tags
    
animalViewEditable animal =
  tr [ emphasizeBorder ]
    [ td []
        [ Bulma.controlRow "Name"
            <| Bulma.soleTextInputInRow [ value (editableName animal)
                                        , Events.onInput (SetEditedName animal.id)
                                        ]
        , Bulma.controlRow "Tags"
            <| Bulma.horizontalControls 
              (List.map (Bulma.deletableTag (DeleteTagWithName animal.id))
                 (editableTags animal))

        , Bulma.controlRow "New Tag"
            <| Bulma.textInputWithSubmit
                 "Add"
                 ((animal_tentativeTag.getOption animal) ? "")
                 (SetTentativeTag animal.id)
                 (CreateNewTag animal.id)
            
        , Bulma.controlRow "Properties"
            <| Bulma.oneReasonablySizedControl
                 (editableAnimalProperties animal |> Bulma.propertyTable)

        , Bulma.leftwardSuccess (SaveAnimalEdit animal.id)
        , Bulma.rightwardCancel (CancelAnimalEdit animal.id)
        ]
    , td [] []
    , td [] []
    , editHelp Bulma.tdIcon
    ]
    
emphasizeBorder =
  style [ ("border-top", "2px solid")
        , ("border-bottom", "2px solid")
        ]
    
boolExplanation b explanation = 
  let
    icon = case b of
             True -> Bulma.trueIcon
             False -> Bulma.falseIcon
    suffix = case explanation of
               Nothing -> ""
               Just s -> " (" ++ s ++ ")"
  in
    [icon, text suffix]


propertyPairs animal =
  Dict.toList (animal.properties)


propertyDisplayValue value =     
  case value of
    AsBool b m -> boolExplanation b m
    AsString s -> [text s]
    _ -> [text "unimplemented"]

propertyEditValue pval =
  case pval of
    AsBool b m ->
      [ Bulma.horizontalControls 
          [ input [type' "checkbox", class "control", checked b]  []
          , Bulma.oneTextInputInRow
              [ value (Maybe.withDefault "" m)
              , placeholder "notes if desired"
              ]
          ]
      ]
    AsString s ->
      [Bulma.soleTextInputInRow [value s]]
    _ -> [text "unimplemented"]

    
animalProperties animal =
  let
    row (key, value) = 
      tr []
        [ td [] [text key]
        , td [] (propertyDisplayValue value)
        ]
  in
      List.map row (propertyPairs animal)

editableAnimalProperties animal =
  let
    row (key, value) = 
      tr []
        [ td [] [text key]
        , td [] (propertyEditValue value)
        ]
  in
      List.map row (propertyPairs animal)

