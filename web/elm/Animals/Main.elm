module Animals.Main exposing (..)

import Navigation
import Animals.Navigation as MyNav
import String

-- Model and Init

type alias Flags =
  { aStringFlag : String
  , aNumberFlag : String
  }
       
type alias Model = 
  { page : MyNav.PageChoice
  , aStringFlag : String
  , aNumberFlag : Int
  }
    
init : Flags -> MyNav.PageChoice -> ( Model, Cmd Msg )
init flags startingLocation =
  ( { page = MyNav.AllAnimalsPage
    , aStringFlag = flags.aStringFlag
    , aNumberFlag = String.toInt flags.aNumberFlag |> Result.withDefault -1
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
    


