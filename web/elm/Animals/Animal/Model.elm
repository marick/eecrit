module Animals.Animal.Model exposing
  (
  ..
  )

import Dict exposing (Dict)
import Date exposing (Date)
import Pile.UpdatingLens as Lens exposing (lens)
import String

type alias Id = String

type DictValue
  = AsInt Int
  | AsFloat Float
  | AsString String
  | AsDate Date
  | AsBool Bool (Maybe String)

type alias Animal =
  { id : Id
  , name : String
  , species : String
  , tags : List String
  , properties : Dict String DictValue
  }

type alias Form = 
  { name : String
  , tags : List String
  , tentativeTag : String
  , properties : Dict String DictValue
  }

type Display
  = Compact
  | Expanded
  | Editable Form
  
type alias DisplayedAnimal = 
  { animal : Animal
  , display : Display
  , flash : Flash
  }

type Flash
  = NoFlash
  | SavedIncompleteTag String
  
extractForm : Animal -> Form
extractForm animal =
  { name = animal.name
  , tags = animal.tags
  , tentativeTag = ""
  , properties = animal.properties
  }

updateAnimal animal form =
  let
    update tags =
      animal 
        |> animal_name.set form.name
        |> animal_properties.set form.properties -- Currently not edited
        |> animal_tags.set tags
  in
    case String.isEmpty form.tentativeTag of
      True ->
        Ok <| update form.tags 
      False ->
        -- Note that this isn't really an Err. Would maybe be better to make
        -- own type?
        Err ( update <| List.append form.tags [form.tentativeTag]
            , SavedIncompleteTag form.tentativeTag
            )

-- Lenses

animal_id = lens .id (\ p w -> { w | id = p })
animal_name = lens .name (\ p w -> { w | name = p })
animal_tags = lens .tags (\ p w -> { w | tags = p })
animal_properties = lens .properties (\ p w -> { w | properties = p })

displayedAnimal_animal = lens .animal (\ p w -> { w | animal = p })
displayedAnimal_id = Lens.compose displayedAnimal_animal animal_id

form_name = lens .name (\ p w -> { w | name = p })
form_tags = lens .tags (\ p w -> { w | tags = p })
form_tentativeTag = lens .tentativeTag (\ p w -> { w | tentativeTag = p })

-- Working with many animals

type alias VisibleAggregate = Dict Id DisplayedAnimal

emptyAggregate : VisibleAggregate
emptyAggregate = Dict.empty

upsert : DisplayedAnimal -> VisibleAggregate -> VisibleAggregate
upsert displayed aggregate =
  let
    key = (displayedAnimal_id.get displayed)
  in
    Dict.insert key displayed aggregate

asAggregate animals =
  let
    tuple animal = (animal.id, DisplayedAnimal animal Compact NoFlash)
  in
    animals |> List.map tuple |> Dict.fromList

