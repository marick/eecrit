module Animals.OutsideWorld.Cmd exposing
  ( fetchAnimals
  , askTodaysDate
  , saveAnimal
  , createAnimal
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
    failureContext = "I could not retrieve animals."
    request = Http.get url (Json.withinData Json.decodeAnimals)
  in
    Http.send (handleResult failureContext SetAnimals) request

saveAnimal animal =
  let
    url = "/api/v2animals/"
    failureContext = "I could not save the animal."
    body = animal |> Json.encodeAnimal |> Json.asData |> Http.jsonBody
    request = Http.post url body (Json.withinData Json.decodeSaveResult)
  in
    Http.send (handleResult failureContext AnimalGotSaved) request

createAnimal animal =
  let
    url = "/api/v2animals/create/" ++ animal.id
    failureContext = "I could not create the animal."
    body = animal |> Json.encodeAnimal |> Json.asData |> Http.jsonBody
    request = Http.post url body (Json.withinData Json.decodeCreationResult)
  in
    Http.send (handleResult failureContext AnimalGotCreated) request

handleResult failureContext msgMaker result =
  case result of
    Ok data ->
      msgMaker data
    Err e ->
      Incoming (HttpError failureContext e)
