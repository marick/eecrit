module Animals.Lenses exposing (..)

import Pile.UpdatingLens as L exposing (..)
import Pile.UpdatingOptional as O exposing (..)

model_page = lens .page (\ p w -> { w | page = p })
