module Animals.Main exposing (..)

import Navigation
import Animals.Navigation as MyNav
import String

-- Model and Init

type alias Flags =
  { csrfToken : String
  }

type alias Animal =
  { name : String
  , species : String
  , tags : List String
  , dateAcquired : String
  , dateRemoved : Maybe String
  }
       
type alias Model = 
  { page : MyNav.PageChoice
  , csrfToken : String
  , animals : List Animal
  }

athena =
  { name = "Athena"
  , species = "bovine"
  , tags = [ "cow" ]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
  }

jake =
  { name = "Jake"
  , species = "equine"
  , tags = [ "gelding" ]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
  }

ross =
  { name = "Ross"
  , species = "equine"
  , tags = [ "stallion", "aggressive"]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
  }

xena =
  { name = "Xena"
  , species = "equine"
  , tags = [ "mare", "skittish" ]
  , dateAcquired = "1 Jan 2016"
  , dateRemoved = Nothing
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

type Msg
  = NavigateToAllPage
  | NavigateToAddPage
  | NavigateToHelpPage

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

goto : Model -> String -> (Model, Cmd Msg)        
goto model path =
  ( model
  , Navigation.newUrl path
  )

-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
