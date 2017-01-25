module Animals.Logic.DisplayedOp exposing (forwardToDisplayed)

import Animals.Model as Model exposing (..)
import Animals.Msg exposing (..)

import Animals.Types.Basic exposing (..)
import Animals.Types.Displayed as Displayed exposing (Displayed)
import Animals.Types.Conversions as Convert
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Lenses exposing (..)

import Animals.Logic.AddPageOp as AddPage

import Animals.Pages.H as Page
import Animals.Pages.Navigation as Page
import Animals.View.AnimalFlash as AnimalFlash

import Pile.Css.H as Css
import Pile.UpdateHelpers exposing (..)
import Pile.ConstrainedStrings as Constrained

{-| Note that displayed operations do NOT empty the flash. This is kind of a
    kludge, but it allows forms in flash to store temporary data instead of
    cluttering up the model.
-}

forwardToDisplayed : Id -> DisplayedOperation -> Model -> (Model, Cmd Msg)
forwardToDisplayed id op model =
  case getDisplayed id model of
    Nothing -> 
      model |> noCmd -- Todo: a command to log the error
    Just displayed -> 
      update op displayed model

update : DisplayedOperation -> Displayed -> Model -> (Model, Cmd Msg)
update op displayed model =
  case op of
    BeginGatheringCopyInfo ->
      model
        |> Model.upsertDisplayed (withGatherFlash displayed "1")
        |> noCmd

    UpdateCopyCount countString ->
      model
        |> Model.upsertDisplayed (withGatherFlash displayed countString)
        |> noCmd

    AddFormsBasedOnAnimal count ->
      model
        |> addAnimalForms displayed count
        |> Model.upsertDisplayed (displayed_flash.set AnimalFlash.NoFlash displayed)
        |> addCmd (Page.toPageChangeCmd Page.AddPage)

addAnimalForms : Displayed -> Int -> Model -> Model
addAnimalForms source count model =
  let
    sourceForm =
      source
        |> Convert.displayedToForm
        |> form_name.set (Form.emptyNameWithNotice)
        |> form_intendedVersion.set 1
  in
    AddPage.addFormsWithIds count (flip form_id.set <| sourceForm) model

withGatherFlash : Displayed -> String -> Displayed      
withGatherFlash displayed string =
  let
    setWith valueMaker correspondingCount =
      displayed_flash.set
        (AnimalFlash.CopyInfoNeeded
           (displayed_id.get displayed)
           (valueMaker string)
           correspondingCount)
        displayed

    -- There is logic that decides, based on a FormValue, whether a
    -- field is submittable. It's not encoded in a type. That is, it's
    -- possible for buggy code to mistakenly allow a bad value to be
    -- submitted. The question is: where should it be decided what value
    -- should be used if the "impossible" happens? It's not clear this
    -- is the best place, but it's the place it's done. One is a good
    -- value to use. Zero would be odd: the user presses a button, the
    -- text field disappears, but nothing happens. Here, at least something
    -- happens, and it's easily reversible. 
    harmlessValue = 1
  in  
    case Constrained.classify_strictlyPositive string of
      Constrained.Blank ->
        setWith Css.silentlyInvalid harmlessValue
      Constrained.DoesNotParse ->
        displayed -- disallow new character
      Constrained.ParsedButWrong _ ->
        setWith Css.silentlyInvalid harmlessValue
      Constrained.Parsed n ->
        setWith Css.freshValue n
