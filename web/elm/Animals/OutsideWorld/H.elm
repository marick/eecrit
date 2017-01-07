module Animals.OutsideWorld.H exposing (..)

import Animals.Animal.Types exposing (..)

-- TODO: This is a pointless indirection. Rather than have
-- pass `AnimalGotSaved (AnimalSaveResults 5)`, just pass
-- pass `AnimalGotSaved 5`.
-- Existing form is a hangover from previous mechanism.

type AnimalSaveResults
  = AnimalUpdated Id 

type AnimalCreationResults
  = AnimalCreated Id Id

