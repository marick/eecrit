module Animals.OutsideWorld.Cmd exposing
  ( fetchAnimals
  , askTodaysDate
  , saveAnimal
  , createAnimal
  )

import Animals.Types.Animal as Animal exposing (Animal)
import Json.Encode as Json
import Animals.OutsideWorld.Json as Json
import Animals.Msg exposing (..)
import Date exposing (Date)
import Date.Extra as Date
import Task
import Http

askTodaysDate : Cmd Msg
askTodaysDate =
  Task.perform SetToday Date.now

fetchAnimals : Date -> Cmd Msg
fetchAnimals date =
  let
    compactDate = Date.toFormattedString "yyyy-MM-dd" date
    url = "/api/v2animals?date=" ++ compactDate -- TODO: Gotta be a better way.
    failureContext = "I could not retrieve animals."
    request = Http.get url (Json.withinData Json.decodeAnimals)
  in
    Http.send
      (handleHtmlResult failureContext (OnAllPage << SetAnimals))
      request

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
