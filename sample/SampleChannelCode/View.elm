module C4u.View exposing (view)

import Html exposing (Html)
import C4u.Main exposing (Model)
import C4u.Msg exposing (Msg)
import C4u.Navigation exposing (PageChoice(..))
import C4u.View.MainPage as MainPage

view : Model -> Html Msg
view model =
  case model.page of
    MainPage -> 
      MainPage.view model
