module Animals.Animal.Lenses exposing (..)

import Pile.UpdatingLens as Lens exposing (lens)

animal_id = lens .id (\ p w -> { w | id = p })
animal_name = lens .name (\ p w -> { w | name = p })
animal_tags = lens .tags (\ p w -> { w | tags = p })
animal_properties = lens .properties (\ p w -> { w | properties = p })

displayedAnimal_animal = lens .animal (\ p w -> { w | animal = p })
displayedAnimal_id = Lens.compose displayedAnimal_animal animal_id

form_name = lens .name (\ p w -> { w | name = p })
form_tags = lens .tags (\ p w -> { w | tags = p })
form_tentativeTag = lens .tentativeTag (\ p w -> { w | tentativeTag = p })


validationForm_name = lens .name (\ p w -> { w | name = p })
validationForm_maySave = lens .maySave (\ p w -> { w | maySave = p })
