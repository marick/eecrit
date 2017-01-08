module Animals.OutsideWorld.Cmd exposing
  ( fetchAnimals
  , askTodaysDate
  , saveAnimal
  , createAnimal
  )

import Animals.Animal.Types exposing (Animal)
import Animals.OutsideWorld.Json as Json
import Animals.Msg exposing (..)
import Date
import Task
import Http

askTodaysDate : Cmd Msg
askTodaysDate =
  Task.perform (SetToday << Just) Date.now

fetchAnimals : Cmd Msg
fetchAnimals =
  let
    url = "/api/v2animals"
    failureContext = "I could not retrieve animals."
    request = Http.get url (Json.withinData Json.decodeAnimals)
  in
    Http.send (handleHtmlResult failureContext SetAnimals) request

saveAnimal : Animal -> Cmd Msg
saveAnimal animal =
  let
    url = "/api/v2animals/"
    failureContext = "I could not save the animal."
    body = animal |> Json.encodeAnimal |> Json.asData |> Http.jsonBody
    request = Http.post url body (Json.withinData Json.decodeSaveResult)
  in
    Http.send (handleHtmlResult failureContext AnimalGotSaved) request

createAnimal : Animal -> Cmd Msg
createAnimal animal =
  let
    url = "/api/v2animals/create/" ++ animal.id
    failureContext = "I could not create the animal."
    body = animal |> Json.encodeAnimal |> Json.asData |> Http.jsonBody
    request = Http.post url body (Json.withinData Json.decodeCreationResult)
  in
    Http.send (handleHtmlResult failureContext AnimalGotCreated) request

-- Private
      
handleHtmlResult : String -> (a -> Msg) -> Result Http.Error a -> Msg
handleHtmlResult failureContext msgMaker result =
  case result of
    Ok data ->
      msgMaker data
    Err e ->
      Incoming (HttpError failureContext e)
