module Animals.Update exposing (..)

import Animals.Model exposing (..)
import Animals.Msg exposing (..)

import Animals.OutsideWorld.H as OutsideWorld
import Animals.OutsideWorld.Update as OutsideWorld

import Animals.Pages.Update as Page
import Animals.View.PageFlash as PageFlash

import Animals.Logic.AnimalOp as AnimalOp
import Animals.Logic.FormOp as FormOp

import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Animals.Types.DisplayedCollections as Displayable
import Animals.View.AnimalFlash as AnimalFlash

import Pile.UpdateHelpers exposing (..)
import Pile.Calendar exposing (EffectiveDate(..))

import List

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  updateWithClearedPageFlash msg (model_pageFlash.set PageFlash.NoFlash model)

updateWithClearedPageFlash : Msg -> Model -> ( Model, Cmd Msg )
updateWithClearedPageFlash msg model =
  case msg of
    WithAnimal animal op ->
      AnimalOp.update op animal model

    WithForm form op ->
      FormOp.update op form model

    Navigate op ->
      Page.update op model

    Incoming op ->
      OutsideWorld.update op model
        
    SetToday value ->
      model |> model_today.set value |> noCmd
    SetAnimals animals ->
      model |> populateAllAnimalsPage animals |> noCmd

    ToggleDatePicker ->
      model |> model_datePickerOpen.update not |> noCmd
    SelectDate date ->
      model |> model_effectiveDate.set (At date) |> noCmd
      
    SetNameFilter s ->
      model |> model_nameFilter.set s |> noCmd
    SetTagFilter s ->
      model |> model_tagFilter.set s |> noCmd
    SetSpeciesFilter s ->
      model |> model_speciesFilter.set s |> noCmd

    AnimalGotSaved (OutsideWorld.AnimalUpdated id) ->
      FormOp.forwardToForm id NoticeSaveResults model 

    AnimalGotCreated (OutsideWorld.AnimalCreated tempId realId) ->
      FormOp.forwardToForm tempId (NoticeCreationResults realId) model

    AddNewAnimals count species ->
      model |> FormOp.addFreshForms count species |> noCmd
          
    NoOp ->
      model ! []

        
populateAllAnimalsPage : List Animal -> Model -> Model 
populateAllAnimalsPage animals model =
  let
    ids =
      List.map .id animals
    compactify animal =
      Displayed (Displayed.Viewable animal) AnimalFlash.NoFlash
    displayables =
      List.map compactify animals
  in
    { model
      | displayables = Displayable.dict displayables
      , allPageAnimals = Displayable.idSet displayables
    }

