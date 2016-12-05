module Animals.Main exposing (..)

import Animals.Types exposing (..)
import Animals.Lenses exposing (..)
import Animals.Msg exposing (..)
import Animals.OutsideWorld as OutsideWorld
import Animals.Animal as Animal
import Animals.Navigation as MyNav

import String
import List
import Date exposing (Date)
import Dict exposing (Dict)
import Pile.Calendar exposing (EffectiveDate(..))
import Return


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of

    MoreLikeThisAnimal id ->
      ( model 
      , Cmd.none
      )

    ExpandAnimal id ->
      transformOne model id (animal_displayState.set Expanded)
    ContractAnimal id ->
      transformOne model id (animal_displayState.set Compact)
    EditAnimal id ->
      transformOne model id (animal_displayState.set Editable >> Animal.makeEditableCopy)
    SetEditedName id name ->
      transformOne model id (animal_editedName.set name)
    DeleteTagWithName id name ->
      transformOne model id (Animal.deleteTag name)
    SetTentativeTag id tag ->
      transformOne model id (animal_tentativeTag.set tag)
    CreateNewTag id ->
      transformOne model id (Animal.promoteTentativeTag)
    CancelAnimalEdit id ->
      transformOne model id (animal_displayState.set Expanded >> Animal.cancelEditableCopy)
    SaveAnimalEdit id ->
      transformOne model id (animal_displayState.set Expanded >> Animal.saveEditableCopy)

    NoOp ->
      model ! []
      

transformOne model id f =
  model_animals.update (Animal.transformAnimal f id) model ! []
