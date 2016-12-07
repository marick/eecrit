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

type alias AnimalProperties =
  Dict String DictValue
    
type alias PersistentAnimal =
  { id : String
  , name : String
  , species : String
  , tags : List String
  , properties : AnimalProperties
  }

type alias ChangingAnimalValues = 
  { name : String
  , tags : List String
  , tentativeTag : String
  , properties : AnimalProperties
  }

type AnimalDisplay
  = Compact
  | Expanded
  | Editable ChangingAnimalValues
  
type alias DisplayedAnimal = 
  { persistent : PersistentAnimal
  , display : AnimalDisplay
  }


-- Working with many animals

asDict animals =
  let
    tuple animal = (animal.id, DisplayedAnimal animal Compact)
  in
    animals |> List.map tuple |> Dict.fromList

-- Lenses

form_name = lens .name (\ p w -> { w | name = p })
form_tags = lens .tags (\ p w -> { w | tags = p })
form_tentativeTag = lens .tentativeTag (\ p w -> { w | tentativeTag = p })
