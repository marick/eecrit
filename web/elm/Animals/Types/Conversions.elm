module Animals.Types.Conversions exposing (..)

import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Displayed as Displayed exposing (Displayed)

import Animals.View.AnimalFlash as AnimalFlash exposing (AnimalFlash)
import Pile.Css.H as Css
import Pile.Namelike as Namelike
import Pile.DateHolder as DateHolder exposing (DateHolder)

import Maybe.Extra as Maybe

-- Starting from an Animal

animalToForm : DateHolder -> Animal -> Form
animalToForm effectiveDate animal =
  { status = Css.AllGood
  , id = animal.id
  , effectiveDate = effectiveDate
  , sortKey = animal.name -- so stays sorted by original name
  , species = animal.species
  , intendedVersion = animal.version + 1
  , name = Css.freshValue animal.name
  , tags = animal.tags
  , tentativeTag = ""
  , properties = animal.properties
  , originalAnimal = Just animal
  }


displayedToForm : DateHolder -> Displayed -> Form
displayedToForm effectiveDate displayed =
  case displayed.view of
    Displayed.Writable form ->
      form
    Displayed.Viewable animal ->
      animalToForm effectiveDate animal

animalToDisplayed : Animal -> Displayed
animalToDisplayed animal =
  { view = Displayed.Viewable animal
  , animalFlash = AnimalFlash.NoFlash
  }

-- Starting from a form
  
finishedFormToDisplayed : Form -> Displayed
finishedFormToDisplayed form =
  { view = Displayed.Viewable <| formToAnimal form
  , animalFlash = formToFlash form
  }

checkedFormToDisplayed : Form -> Displayed
checkedFormToDisplayed form =
  { view = Displayed.Writable form
  , animalFlash = AnimalFlash.NoFlash
  }

formToAnimal : Form -> Animal
formToAnimal form =
  { id = form.id
  , displayFormat = Animal.Expanded
  , version = form.intendedVersion
  , name = form.name.value
  , species = form.species
  , tags = Namelike.perhapsAdd form.tentativeTag form.tags
  , properties = form.properties
  , creationDate = Form.animalCreationDate form
  }

formToFlash : Form -> AnimalFlash
formToFlash form =
  case Namelike.isValidAddition form.tentativeTag form.tags of
    True -> AnimalFlash.SavedIncompleteTag form.tentativeTag
    False -> AnimalFlash.NoFlash

