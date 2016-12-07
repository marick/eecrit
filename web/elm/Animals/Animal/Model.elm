module Animals.Animal.Model exposing
  (
  ..
  )

import Dict exposing (Dict)
import Date exposing (Date)
import Pile.UpdatingLens exposing (lens)

type DictValue
  = AsInt Int
  | AsFloat Float
  | AsString String
  | AsDate Date
  | AsBool Bool (Maybe String)

type alias Animal =
  { id : String
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
  }

extractForm : Animal -> Form
extractForm animal =
  { name = animal.name
  , tags = animal.tags
  , tentativeTag = ""
  , properties = animal.properties
  }

applyEdits animal form =
  { animal
      | name = form.name
      , tags = form.tags
      , properties = form.properties
  }


-- Lenses

form_name = lens .name (\ p w -> { w | name = p })
form_tags = lens .tags (\ p w -> { w | tags = p })
form_tentativeTag = lens .tentativeTag (\ p w -> { w | tentativeTag = p })

-- Working with many animals

asDict animals =
  let
    tuple animal = (animal.id, DisplayedAnimal animal Compact)
  in
    animals |> List.map tuple |> Dict.fromList

