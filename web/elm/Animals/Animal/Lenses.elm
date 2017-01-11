module Animals.Animal.Lenses exposing (..)

import Pile.UpdatingLens as Lens exposing (UpdatingLens, lens)
import Pile.Bulma as Bulma exposing (FormValue, FormStatus)
import Pile.Namelike exposing (Namelike)
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

animal_displayFormat : UpdatingLens Animal Format
animal_displayFormat = lens .displayFormat (\ p w -> { w | displayFormat = p })
                    
-- displayedAnimal_animal : UpdatingLens DisplayedAnimal Animal
-- displayedAnimal_animal = lens .animal (\ p w -> { w | animal = p })

-- displayedAnimal_format : UpdatingLens DisplayedAnimal Format
-- displayedAnimal_format = lens .format (\ p w -> { w | format = p })

-- displayedAnimal_flash : UpdatingLens DisplayedAnimal AnimalFlash
-- displayedAnimal_flash = lens .animalFlash (\ p w -> { w | animalFlash = p })

-- displayedAnimal_id : UpdatingLens DisplayedAnimal Id
-- displayedAnimal_id = Lens.compose displayedAnimal_animal animal_id

-- displayedAnimal_name : UpdatingLens DisplayedAnimal String
-- displayedAnimal_name = Lens.compose displayedAnimal_animal animal_name


formValue_value : UpdatingLens (FormValue t) t
formValue_value = lens .value (\ p w -> { w | value = p })

                       
form_id : UpdatingLens Form Id
form_id = lens .id (\ p w -> { w | id = p })

form_name : UpdatingLens Form (FormValue Namelike)
form_name = lens .name (\ p w -> { w | name = p })

form_name_value : UpdatingLens Form Namelike
form_name_value = Lens.compose form_name formValue_value

form_tags : UpdatingLens Form (List Namelike)
form_tags = lens .tags (\ p w -> { w | tags = p })

form_species : UpdatingLens Form Namelike
form_species = lens .species (\ p w -> { w | species = p })

form_tentativeTag : UpdatingLens Form String
form_tentativeTag = lens .tentativeTag (\ p w -> { w | tentativeTag = p })

form_status : UpdatingLens Form FormStatus
form_status = lens .status (\ p w -> { w | status = p })

form_originalAnimal : UpdatingLens Form Animal
form_originalAnimal = lens .originalAnimal (\ p w -> { w | originalAnimal = p })

form_originalName : UpdatingLens Form Namelike
form_originalName = Lens.compose form_originalAnimal animal_name
              
validationContext_disallowedNames : UpdatingLens ValidationContext (List String)
validationContext_disallowedNames = lens .disallowedNames (\ p w -> { w | disallowedNames = p })     


makeLens_traversingDisplayView : UpdatingLens Form part ->
                                 UpdatingLens Animal part -> 
                                 UpdatingLens Displayed part
makeLens_traversingDisplayView formLens animalLens  = 
  lens
  (\ w ->
     case w.view of
       Writable form -> formLens.get form
       Viewable animal -> animalLens.get animal
  )
  (\ p w ->
     { w | view =
         case w.view of
           Writable form -> formLens.set p form |> Writable
           Viewable animal -> animalLens.set p animal |> Viewable
     }
  )

displayed_tags : UpdatingLens Displayed (List Namelike)
displayed_tags = makeLens_traversingDisplayView form_tags animal_tags

displayed_name : UpdatingLens Displayed Namelike
displayed_name = makeLens_traversingDisplayView form_name_value animal_name

displayed_species : UpdatingLens Displayed Namelike
displayed_species = makeLens_traversingDisplayView form_species animal_species
