module Animals.Lenses exposing (..)

import Animals.Types exposing (..)
import Pile.UpdatingLens as L exposing (..)
import Pile.UpdatingOptional as O exposing (..)

model_page = lens .page (\ p w -> { w | page = p })
model_today = lens .today (\ p w -> { w | today = p })
model_animals = lens .animals (\ p w -> { w | animals = p })

animal_displayState = lens .displayState (\ p w -> { w | displayState = p })

animal_editableCopy = opt .editableCopy (\ p w -> { w | editableCopy = Just p })
editableCopy_name = lens .name (\ p w -> { w | name = p })
editableCopy_tags = lens .tags (\ p w -> { w | tags = p })
                            
animal_editedName = O.composeLens animal_editableCopy editableCopy_name
animal_editedTags = O.composeLens animal_editableCopy editableCopy_tags
      
