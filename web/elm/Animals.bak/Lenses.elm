module Animals.Lenses exposing (..)

import Animals.Types exposing (..)
import Pile.UpdatingLens as L exposing (..)
import Pile.UpdatingOptional as O exposing (..)

model_today = lens .today (\ p w -> { w | today = p })
model_animals = lens .animals (\ p w -> { w | animals = p })
model_tagFilter = lens .tagFilter (\ p w -> { w | tagFilter = p })
model_speciesFilter = lens .speciesFilter (\ p w -> { w | speciesFilter = p })
model_nameFilter = lens .nameFilter (\ p w -> { w | nameFilter = p })
model_effectiveDate = lens .effectiveDate (\ p w -> { w | effectiveDate = p })
model_datePickerOpen = lens .datePickerOpen (\ p w -> { w | datePickerOpen = p })

animal_displayState = lens .displayState (\ p w -> { w | displayState = p })

animal_editableCopy = opt .editableCopy (\ p w -> { w | editableCopy = Just p })
editableCopy_name = lens .name (\ p w -> { w | name = p })
editableCopy_tags = lens .tags (\ p w -> { w | tags = p })
editableCopy_tentativeTag = lens .tentativeTag (\ p w -> { w | tentativeTag = p })
                            
animal_editedName = O.composeLens animal_editableCopy editableCopy_name
animal_editedTags = O.composeLens animal_editableCopy editableCopy_tags
animal_tentativeTag = O.composeLens animal_editableCopy editableCopy_tentativeTag
