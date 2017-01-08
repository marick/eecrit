module Animals.Animal.Lenses exposing (..)

import Pile.UpdatingLens as Lens exposing (UpdatingLens, lens)
import Pile.Bulma as Bulma exposing (FormValue, FormStatus)
import Animals.Animal.Types exposing (..)
import Animals.Animal.Flash as Flash exposing (AnimalFlash(..))

type alias FormLens field = UpdatingLens Form (FormValue field)

animal_id : UpdatingLens Animal Id
animal_id = lens .id (\ p w -> { w | id = p })

animal_species : UpdatingLens Animal String
animal_species = lens .species (\ p w -> { w | species = p })

animal_version : UpdatingLens Animal Int
animal_version = lens .version (\ p w -> { w | version = p })

animal_name : UpdatingLens Animal String
animal_name = lens .name (\ p w -> { w | name = p })

animal_tags : UpdatingLens Animal (List String)
animal_tags = lens .tags (\ p w -> { w | tags = p })

animal_properties : UpdatingLens Animal Properties
animal_properties = lens .properties (\ p w -> { w | properties = p })

                    
displayedAnimal_animal : UpdatingLens DisplayedAnimal Animal
displayedAnimal_animal = lens .animal (\ p w -> { w | animal = p })

displayedAnimal_format : UpdatingLens DisplayedAnimal Format
displayedAnimal_format = lens .format (\ p w -> { w | format = p })

displayedAnimal_flash : UpdatingLens DisplayedAnimal AnimalFlash
displayedAnimal_flash = lens .animalFlash (\ p w -> { w | animalFlash = p })

displayedAnimal_id : UpdatingLens DisplayedAnimal Id
displayedAnimal_id = Lens.compose displayedAnimal_animal animal_id

displayedAnimal_name : UpdatingLens DisplayedAnimal String
displayedAnimal_name = Lens.compose displayedAnimal_animal animal_name

form_id : UpdatingLens Form Id
form_id = lens .id (\ p w -> { w | id = p })

form_name : UpdatingLens Form (FormValue String)
form_name = lens .name (\ p w -> { w | name = p })

form_tags : UpdatingLens Form (List String)
form_tags = lens .tags (\ p w -> { w | tags = p })

form_tentativeTag : UpdatingLens Form String
form_tentativeTag = lens .tentativeTag (\ p w -> { w | tentativeTag = p })

form_status : UpdatingLens Form FormStatus
form_status = lens .status (\ p w -> { w | status = p })

validationContext_disallowedNames : UpdatingLens ValidationContext (List String)
validationContext_disallowedNames = lens .disallowedNames (\ p w -> { w | disallowedNames = p })     

