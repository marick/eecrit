module Animals.OutsideWorld.Declare exposing (..)

import Animals.Animal.Types exposing (..)

type alias Version = Int

type AnimalSaveResults
  = AnimalUpdated Id 

type AnimalCreationResults
  = AnimalCreated Id Id

