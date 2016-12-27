module Animals.OutsideWorld.Declare exposing (..)

import Animals.Animal.Types exposing (..)

import Dict exposing (Dict)

type alias Version = Int

type AnimalSaveResults
  = AnimalUpdated Id Version

type AnimalCreationResults
  = AnimalCreated Id Id

