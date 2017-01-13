module Animals.Update exposing (..)

import Animals.Model exposing (..)
import Animals.Msg exposing (..)

import Animals.OutsideWorld.H as OutsideWorld
import Animals.OutsideWorld.Cmd as OutsideWorld
import Animals.OutsideWorld.Update as OutsideWorld

import Animals.Pages.Update as Page
import Animals.View.PageFlash as PageFlash

import Animals.Logic.AnimalOp as AnimalOp
import Animals.Logic.FormOp as FormOp

import Animals.Types.Basic exposing (..)
import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Animals.Types.DisplayedCollections as Displayable
import Animals.Types.Lenses exposing (..)
import Animals.Types.Conversions as Convert
import Animals.Logic.Validation as Validation
import Animals.View.AnimalFlash as AnimalFlash

import Pile.UpdateHelpers exposing (..)
import Pile.Calendar exposing (EffectiveDate(..))
import Pile.Namelike as Namelike exposing (Namelike)
import Pile.Css.H as Css
import Pile.Css.Bulma as Css

import Set exposing (Set)
import List
import List.Extra as List
import Dict exposing (Dict)
-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  updateWithClearedPageFlash msg (model_pageFlash.set PageFlash.NoFlash model)

updateWithClearedPageFlash : Msg -> Model -> ( Model, Cmd Msg )
updateWithClearedPageFlash msg model =
  case msg of
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
          
    WithAnimal animal op ->
      AnimalOp.update op animal model

    WithForm form op ->
      FormOp.update op form model

    Page op ->
      Page.update op model

    Incoming op ->
      OutsideWorld.update op model
        
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

