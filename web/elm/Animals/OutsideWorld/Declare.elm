module Animals.OutsideWorld.Declare exposing (..)

import Animals.Animal.Types exposing (..)

import Dict exposing (Dict)

type AnimalSaveResults
  = AnimalUpdated Id Int

type alias SuccessfulAnimalCreation = 
  { temporaryId : Id
  , permanentId : Id
  }

