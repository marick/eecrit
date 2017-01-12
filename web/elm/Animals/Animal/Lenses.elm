module Animals.Animal.Lenses exposing (..)

import Animals.Types.Animal exposing (..)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Pile.UpdatingLens as Lens exposing (UpdatingLens, lens)
import Animals.Types.Basic exposing (..)
import Pile.Css.H as Css
import Pile.Namelike exposing (Namelike)

type alias FormLens field = UpdatingLens Form (Css.FormValue field)

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
                    

formValue_value : UpdatingLens (Css.FormValue t) t
formValue_value = lens .value (\ p w -> { w | value = p })

                       
form_id : UpdatingLens Form Id
form_id = lens .id (\ p w -> { w | id = p })

form_name : UpdatingLens Form (Css.FormValue Namelike)
form_name = lens .name (\ p w -> { w | name = p })

form_name_value : UpdatingLens Form Namelike
form_name_value = Lens.compose form_name formValue_value

form_tags : UpdatingLens Form (List Namelike)
form_tags = lens .tags (\ p w -> { w | tags = p })

form_species : UpdatingLens Form Namelike
form_species = lens .species (\ p w -> { w | species = p })

form_tentativeTag : UpdatingLens Form String
form_tentativeTag = lens .tentativeTag (\ p w -> { w | tentativeTag = p })

form_status : UpdatingLens Form Css.FormStatus
form_status = lens .status (\ p w -> { w | status = p })

validationContext_disallowedNames : UpdatingLens Form.ValidationContext (List String)
validationContext_disallowedNames = lens .disallowedNames (\ p w -> { w | disallowedNames = p })     


makeLens_traversingDisplayView : UpdatingLens Form part ->
                                 UpdatingLens Animal part -> 
                                 UpdatingLens Displayed part
makeLens_traversingDisplayView formLens animalLens  = 
  lens
  (\ w ->
     case w.view of
       Displayed.Writable form -> formLens.get form
       Displayed.Viewable animal -> animalLens.get animal
  )
  (\ p w ->
     { w | view =
         case w.view of
           Displayed.Writable form -> formLens.set p form |> Displayed.Writable
           Displayed.Viewable animal -> animalLens.set p animal |> Displayed.Viewable
     }
  )

displayed_id : UpdatingLens Displayed Id
displayed_id = makeLens_traversingDisplayView form_id animal_id

displayed_name : UpdatingLens Displayed Namelike
displayed_name = makeLens_traversingDisplayView form_name_value animal_name

displayed_tags : UpdatingLens Displayed (List Namelike)
displayed_tags = makeLens_traversingDisplayView form_tags animal_tags

displayed_species : UpdatingLens Displayed Namelike
displayed_species = makeLens_traversingDisplayView form_species animal_species
