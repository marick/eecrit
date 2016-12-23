module Animals.Animal.Lenses exposing (..)

import Pile.UpdatingLens as Lens exposing (UpdatingLens, lens)
import Pile.Bulma as Bulma exposing (FormValue)
import Animals.Animal.Types exposing (Form)

--- type alias StringLens record = UpdatingLens record (FormValue String)

type alias FormLens field = UpdatingLens Form (FormValue field)

animal_id = lens .id (\ p w -> { w | id = p })
animal_version = lens .version (\ p w -> { w | version = p })
animal_name = lens .name (\ p w -> { w | name = p })
animal_wasEverSaved = lens .wasEverSaved (\ p w -> { w | wasEverSaved = p })
animal_tags = lens .tags (\ p w -> { w | tags = p })
animal_properties = lens .properties (\ p w -> { w | properties = p })

display_flash = lens .animalFlash (\ p w -> { w | animalFlash = p })
                    
displayedAnimal_animal = lens .animal (\ p w -> { w | animal = p })
displayedAnimal_display = lens .display (\ p w -> { w | display = p })
displayedAnimal_id = Lens.compose displayedAnimal_animal animal_id
displayedAnimal_name = Lens.compose displayedAnimal_animal animal_name
displayedAnimal_wasEverSaved = Lens.compose displayedAnimal_animal animal_wasEverSaved
displayedAnimal_flash = Lens.compose displayedAnimal_display display_flash

form_name = lens .name (\ p w -> { w | name = p })
form_tags = lens .tags (\ p w -> { w | tags = p })
form_tentativeTag = lens .tentativeTag (\ p w -> { w | tentativeTag = p })
form_isValid = lens .isValid (\ p w -> { w | isValid = p })

validationContext_disallowedNames = lens .disallowedNames (\ p w -> { w | disallowedNames = p })     

validationForm_name = lens .name (\ p w -> { w | name = p })
validationForm_maySave = lens .maySave (\ p w -> { w | maySave = p })
