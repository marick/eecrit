module Animals.Animal.Lenses exposing (..)

import Pile.UpdatingLens as Lens exposing (UpdatingLens, lens)
import Pile.Bulma as Bulma exposing (FormValue)

type alias StringLens record = UpdatingLens record (FormValue String)

animal_id = lens .id (\ p w -> { w | id = p })
animal_version = lens .version (\ p w -> { w | version = p })
animal_name = lens .name (\ p w -> { w | name = p })
animal_wasEverSaved = lens .wasEverSaved (\ p w -> { w | wasEverSaved = p })
animal_tags = lens .tags (\ p w -> { w | tags = p })
animal_properties = lens .properties (\ p w -> { w | properties = p })

displayedAnimal_animal = lens .animal (\ p w -> { w | animal = p })
displayedAnimal_id = Lens.compose displayedAnimal_animal animal_id
displayedAnimal_name = Lens.compose displayedAnimal_animal animal_name
displayedAnimal_wasEverSaved = Lens.compose displayedAnimal_animal animal_wasEverSaved

form_name_v2 = lens .name_v2 (\ p w -> { w | name_v2 = p })
form_tags = lens .tags (\ p w -> { w | tags = p })
form_tentativeTag = lens .tentativeTag (\ p w -> { w | tentativeTag = p })

validationContext_allAnimalNames = lens .allAnimalNames (\ p w -> { w | allAnimalNames = p })     

validationForm_name = lens .name (\ p w -> { w | name = p })
validationForm_maySave = lens .maySave (\ p w -> { w | maySave = p })
