module Animals.OutsideWorld.Cmd exposing
  ( fetchAnimals
  , animalHistory
  , askTodaysDate
  , saveAnimal
  , createAnimal
  )

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal as Animal exposing (Animal)
import Animals.OutsideWorld.Encode as Encode
import Animals.OutsideWorld.Decode as Decode
import Animals.Msg exposing (..)
import Date exposing (Date)
import Pile.Date as Date
import Task
import Http
import Pile.DateHolder as DateHolder exposing (DateHolder)
import Pile.Namelike as Namelike exposing (Namelike)


askTodaysDate : Cmd Msg
askTodaysDate =
  Task.perform SetToday Date.now

fetchAnimals : Date -> Cmd Msg
fetchAnimals date =
  let
    compactDate = Date.logical date
    url = "/api/v2animals?date=" ++ compactDate -- TODO: Gotta be a better way.
    failureContext = "I could not retrieve animals."
    request = Http.get url (Decode.withinData Decode.animals)
  in
    Http.send
      (handleHtmlResult failureContext (OnAllPage << SetAnimals))
      request

saveAnimal : DateHolder -> Animal -> Cmd Msg
saveAnimal effectiveDate animal =
  let
    url = "/api/v2animals/"
    failureContext = "I could not save the animal."
    body = animalBody effectiveDate animal
    request = Http.post url body (Decode.withinData Decode.saveResponse)
  in
    Http.send (handleHtmlResult failureContext AnimalGotSaved) request

createAnimal : DateHolder -> Animal -> Cmd Msg
createAnimal effectiveDate animal =
  let
    url = "/api/v2animals/create/" ++ animal.id
    failureContext = "I could not create the animal."
    body = animalBody effectiveDate animal
    request = Http.post url body (Decode.withinData Decode.creationResponse)
  in
    Http.send (handleHtmlResult failureContext AnimalGotCreated) request

animalHistory : Id -> Namelike -> Cmd Msg
animalHistory id name = 
  let
    url = "/api/v2animals/" ++ id ++ "/history"
    failureContext = "I could not retrieve the history for animal " ++ name ++ "."
    request = Http.get url (Decode.withinData Decode.history)
  in
    Http.send
      (handleHtmlResult failureContext (OnHistoryPage id << SetHistory))
      request

-- Private

animalBody : DateHolder -> Animal -> Http.Body
animalBody effectiveDate animal = 
  animal
    |> Encode.animal
    |> Encode.addingMetadata effectiveDate
    |> Http.jsonBody

handleHtmlResult : String -> (a -> Msg) -> Result Http.Error a -> Msg
handleHtmlResult failureContext msgMaker result =
  case result of
    Ok data ->
      msgMaker data
    Err e ->
      Incoming (HttpError failureContext e)
