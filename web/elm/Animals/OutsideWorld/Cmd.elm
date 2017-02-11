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
import Pile.Date as Date
import Task
import Http
import Pile.DateHolder as DateHolder exposing (DateHolder)


askTodaysDate : Cmd Msg
askTodaysDate =
  Task.perform SetToday Date.now

fetchAnimals : Date -> Cmd Msg
fetchAnimals date =
  let
    compactDate = Date.logical date
    url = "/api/v2animals?date=" ++ compactDate -- TODO: Gotta be a better way.
    failureContext = "I could not retrieve animals."
    request = Http.get url (Json.withinData Json.decodeAnimals)
  in
    Http.send
      (handleHtmlResult failureContext (OnAllPage << SetAnimals))
      request

saveAnimal : DateHolder -> Animal -> Cmd Msg
saveAnimal effectiveDate animal =
  let
    url = "/api/v2animals/"
    failureContext = "I could not save the animal."
    body = animalInstructions effectiveDate animal
    request = Http.post url body (Json.withinData Json.decodeSaveResult)
  in
    Http.send (handleHtmlResult failureContext AnimalGotSaved) request

createAnimal : DateHolder -> Animal -> Cmd Msg
createAnimal effectiveDate animal =
  let
    url = "/api/v2animals/create/" ++ animal.id
    failureContext = "I could not create the animal."
    body = animalInstructions effectiveDate animal
    request = Http.post url body (Json.withinData Json.decodeCreationResult)
  in
    Http.send (handleHtmlResult failureContext AnimalGotCreated) request

-- Private

animalInstructions effectiveDate animal = 
  animal
    |> Json.encodeOutgoingAnimal (DateHolder.convertToDate effectiveDate)
    |> Json.animalInstructions effectiveDate
    |> Http.jsonBody

handleHtmlResult : String -> (a -> Msg) -> Result Http.Error a -> Msg
handleHtmlResult failureContext msgMaker result =
  case result of
    Ok data ->
      msgMaker data
    Err e ->
      Incoming (HttpError failureContext e)
