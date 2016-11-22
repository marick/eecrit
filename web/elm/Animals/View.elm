module Animals.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App exposing (programWithFlags)
import Html.Events as Events

import Animals.Main exposing (Model, Msg)
import Animals.Navigation exposing (PageChoice(..))

view : Model -> Html Msg
view model =
  p []
    [text <| "A new Animal has been started with argument \""
       ++ model.aStringFlag ++ "\" and "
       ++ toString(model.aNumberFlag)]

