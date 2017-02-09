module Animals.Update exposing (..)

import Animals.Model exposing (..)
import Animals.Msg exposing (..)
import Animals.Types.Lenses exposing (..)

import Animals.OutsideWorld.H as OutsideWorld
import Animals.OutsideWorld.Cmd as OutsideWorld
import Animals.OutsideWorld.Update as OutsideWorld

import Animals.Types.Conversions as Convert
import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.AnimalHistory as AnimalHistory
import Animals.Types.DisplayedCollections as Displayable

import Animals.Logic.AnimalOp as AnimalOp
import Animals.Logic.FormOp as FormOp
import Animals.Logic.DisplayedOp as DisplayedOp
import Animals.Logic.AllPageOp as AllPageOp
import Animals.Logic.AddPageOp as AddPageOp

import Animals.Pages.Update as Page
import Animals.View.PageFlash as PageFlash

import Pile.UpdateHelpers exposing (..)

import List
import Set
import Dict

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  updateWithClearedPageFlash msg (model_pageFlash.set PageFlash.NoFlash model)

updateWithClearedPageFlash : Msg -> Model -> ( Model, Cmd Msg )
updateWithClearedPageFlash msg model =
  case msg of
    OnAllPage op ->
      AllPageOp.update op model
    
    OnAddPage op ->
      AddPageOp.update op model
    
    WithAnimal animal op ->
      AnimalOp.update op animal model

    WithForm form op ->
      FormOp.update op form model

    WithDisplayedId id op ->
      DisplayedOp.forwardToDisplayed id op model

    Navigate op ->
      Page.update op model

    Incoming op ->
      OutsideWorld.update op model
        
    SetToday value ->
      model |> model_today.set value |> addCmd (OutsideWorld.fetchAnimals value)

    AnimalGotSaved (OutsideWorld.AnimalUpdated id) ->
      FormOp.forwardToForm id NoticeSaveResults model 

    AnimalGotCreated (OutsideWorld.AnimalCreated tempId realId) ->
      FormOp.forwardToForm tempId (NoticeCreationResults realId) model

    NewHistoryPage animal ->
      let
        upsert = upsertHistoryPage animal.id (AnimalHistory.fresh animal)
        order = placeHistoryInOrder animal.id
      in
        case Dict.get animal.id model.historyPages of
          Nothing ->
            model |> upsert |> order |> noCmd
          Just _ ->
            model |> upsert |> noCmd
        
    NoOp ->
      model ! []

        
