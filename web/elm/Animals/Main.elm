module Animals.Main exposing (..)

import Navigation
import Animals.Navigation as MyNav
import String

-- Model and Init

type alias Flags =
  { authToken : String
  , desire : String
  }
       
type alias Model = 
  { page : MyNav.PageChoice
  , authToken : String
  }


init : Flags -> MyNav.PageChoice -> ( Model, Cmd Msg )
init flags startingLocation =
  ( { page = MyNav.desireToPage(flags.desire)
    , authToken = flags.authToken
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
    ToAllPage ->
      ( { model | page = MyNav.AllPage }
      , Cmd.none )
    ToAddPage ->
      ( { model | page = MyNav.AddPage }
      , Cmd.none )
    ToHelpPage ->
      ( { model | page = MyNav.HelpPage }
      , Cmd.none )



-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
