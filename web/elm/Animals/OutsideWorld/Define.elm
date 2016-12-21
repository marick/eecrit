module Animals.OutsideWorld.Define exposing
  ( fetchAnimals
  , askTodaysDate
  , saveAnimal
  )
import Animals.OutsideWorld.Json as Json
import Animals.Animal.Types exposing (..)
import Animals.Msg exposing (..)
import Date
import Dict exposing (Dict)
import Task
import Http

askTodaysDate =
  Task.perform (SetToday << Just) Date.now

fetchAnimals =
  let
    url = "/api/v2animals"
    request = Http.get url (Json.withinData Json.decodeAnimals)
  in
    Http.send SetAnimals request

saveAnimal animal =
  let
    url = "/api/v2animals"
    body = animal |> Json.encodeAnimal |> Json.asData |> Http.jsonBody
    request = Http.post url body (Json.withinData Json.decodeSaveResult)
  in
    Http.send NoticeAnimalSaveResults request




-- Animal creation

-- persistNewAnimal animal =
--   Task.perform Ok (Task.succeed { temporaryId = animal.id, newId = "newid" })

-- saveAnimal animal = 
--   Task.perform NoticeAnimalSaveResults (Task.succeed (Ok (AnimalUpdated animal.id 83))

---


---
    
