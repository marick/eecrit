module Animals.Types.Conversions exposing (..)

import Animals.Types.Animal as Animal exposing (Animal)
import Animals.Types.Form as Form exposing (Form)
import Animals.Types.Displayed as Displayed exposing (Displayed)

import Animals.View.AnimalFlash as AnimalFlash exposing (AnimalFlash)
import Pile.Css.H as Css
import Pile.Namelike as Namelike

-- Starting from an Animal

animalToForm : Animal -> Form
animalToForm animal =
  { status = Css.AllGood
  , id = animal.id
  , sortKey = animal.name -- so stays sorted by original name
  , species = animal.species
  , intendedVersion = animal.version + 1
  , name = Css.freshValue animal.name
  , tags = animal.tags
  , tentativeTag = ""
  , properties = animal.properties
  , originalAnimal = Just animal
  }

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
  }

formToFlash : Form -> AnimalFlash
formToFlash form =
  case Namelike.isValidAddition form.tentativeTag form.tags of
    True -> AnimalFlash.SavedIncompleteTag form.tentativeTag
    False -> AnimalFlash.NoFlash


