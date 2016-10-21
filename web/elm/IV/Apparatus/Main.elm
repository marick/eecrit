module IV.Apparatus.Main exposing (..)

import IV.Apparatus.Droplet as Droplet
import IV.Apparatus.BagLevel as BagLevel
import IV.Types exposing (..)

type alias Model =
  { foo : String }

unstarted = { foo = "bar" }

animations model = 
  [model.droplet, model.bagLevel]
