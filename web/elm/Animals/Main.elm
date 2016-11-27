module Animals.Main exposing (..)

import Navigation
import Animals.Navigation as MyNav
import String
import List

-- Model and Init

type alias Flags =
  { csrfToken : String
  }

type DisplayState
  = Compact
  | Expanded
  | Editable

type alias Animal =
  { id : String
  , name : String
  , species : String
  , tags : List String
  , dateAcquired : String
  , dateRemoved : Maybe String
  , displayState : DisplayState
  }
       
type alias Model = 
  { page : MyNav.PageChoice
  , csrfToken : String
  , animals : List Animal
  }

athena =
  { id = "1"
  , name = "Athena"
  , species = "bovine"
  , tags = [ "cow" ]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
  , displayState = Compact
  }

jake =
  { id = "2"
  , name = "Jake"
  , species = "equine"
  , tags = [ "gelding" ]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
  , displayState = Compact
  }

ross =
  { id = "3"
  , name = "Ross"
  , species = "equine"
  , tags = [ "stallion", "aggressive"]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
  , displayState = Compact
  }

xena =
  { id = "4"
  , name = "Xena"
  , species = "equine"
  , tags = [ "mare", "skittish" ]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
  , displayState = Compact
  }

init : Flags -> MyNav.PageChoice -> ( Model, Cmd Msg )
init flags startingPage =
  ( { page = startingPage
    , csrfToken = flags.csrfToken
    , animals = [athena, jake, ross, xena]
    }
  , Cmd.none
  )


-- Msg

type alias Id = String

type Msg
  = NavigateToAllPage
  | NavigateToAddPage
  | NavigateToHelpPage

  | ExpandAnimal Id
  | ContractAnimal Id
  | EditAnimal Id
  | MoreLikeThisAnimal Id

-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NavigateToAllPage ->
      goto model MyNav.allPagePath
    NavigateToAddPage ->
      goto model MyNav.addPagePath
    NavigateToHelpPage ->
      goto model MyNav.helpPagePath
    ExpandAnimal id ->
      ( { model | animals = toState Expanded id model.animals }
      , Cmd.none
      )
    ContractAnimal id ->
      ( { model | animals = toState Compact id model.animals }
      , Cmd.none
      )
    EditAnimal id ->
      ( model
      , Cmd.none
      )
    MoreLikeThisAnimal id ->
      ( model 
      , Cmd.none
      )

transformAnimal pred transformer animal =
  if pred animal then
    transformer animal
  else
    animal
      
toState newState id animals =
  List.map
    (transformAnimal (\ a -> a.id == id)
       (\ a -> { a | displayState = newState }))
    animals

      
goto : Model -> String -> (Model, Cmd Msg)        
goto model path =
  ( model
  , Navigation.newUrl path
  )

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
