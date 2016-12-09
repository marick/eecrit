module Animals.Animal.Model exposing
  (
  ..
  )

import Dict exposing (Dict)
import Date exposing (Date)
import Pile.UpdatingLens as Lens exposing (lens)

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
  , warning : Warning
  }

type Warning 
  = AllGood
  | AutoSavedTagWarning String
  
extractForm : Animal -> Form
extractForm animal =
  { name = animal.name
  , tags = animal.tags
  , tentativeTag = ""
  , properties = animal.properties
  }

updateAnimal animal form =   
  let
    newAnimal =
      { animal
        | name = form.name
        , tags = form.tags
        , properties = form.properties
      }
  in
    (newAnimal, AllGood)

-- Lenses

animal_id = lens .id (\ p w -> { w | id = p })

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
    tuple animal = (animal.id, DisplayedAnimal animal Compact (AutoSavedTagWarning "foo"))
  in
    animals |> List.map tuple |> Dict.fromList

