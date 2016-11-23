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
      ( { model | page = MyNav.AllPage }
      , Cmd.none )
    NavigateToAddPage ->
      ( { model | page = MyNav.AddPage }
      , Cmd.none )
    NavigateToHelpPage ->
      ( { model | page = MyNav.HelpPage }
      , Cmd.none )



-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
