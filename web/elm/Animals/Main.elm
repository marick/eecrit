module Animals.Main exposing (..)

import Navigation
import Animals.Navigation as MyNav
import String

-- Model and Init

type alias Flags =
  { csrfToken : String
  }
       
type alias Model = 
  { page : MyNav.PageChoice
  , csrfToken : String
  }


init : Flags -> MyNav.PageChoice -> ( Model, Cmd Msg )
init flags startingPage =
  ( { page = startingPage
    , csrfToken = flags.csrfToken
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
