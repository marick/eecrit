module Animals.Main exposing (..)

import Navigation
import Animals.Navigation as MyNav
import String

-- Model and Init

type alias Flags =
  { authToken : String
  , page : String
  }
       
type alias Model = 
  { page : MyNav.PageChoice
  , authToken : String
  , givenPage : String
  }
    
init : Flags -> MyNav.PageChoice -> ( Model, Cmd Msg )
init flags startingLocation =
  ( { page = MyNav.AllAnimalsPage
    , authToken = flags.authToken
    , givenPage = flags.page
    }
  , Cmd.none
  )


-- Msg

type Msg
  = NoOp

-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      ( model, Cmd.none )



-- Subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
