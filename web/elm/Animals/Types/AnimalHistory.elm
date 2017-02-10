module Animals.Types.AnimalHistory exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal exposing (Animal)
import Date exposing (Date)
import Date.Extra as Date
import Pile.Namelike exposing (Namelike)

type alias AuditStamp =
  { author : String
  , date: Date
  }

type alias Entry = 
  { audit : AuditStamp
  , effectiveDate : Date
  , nameChange : Maybe Namelike
  , newTags : List Namelike
  , deletedTags : List Namelike
  }

type alias History =
  { id : Id
  , name : String
  , entries : List Entry 
  }


fresh animal =
  { id = animal.id
  , name = animal.name
  , entries = []
  }
