module IV.View exposing (view)

import Html exposing (Html)
import IV.Main exposing (Model)
import IV.Msg exposing (Msg)
import IV.Navigation exposing (PageChoice(..))
import IV.View.MainPage as MainPage
import IV.View.AboutPage as AboutPage

view : Model -> Html Msg
view model =
  case model.page of
    MainPage -> 
      MainPage.view model
    AboutPage ->
      AboutPage.view
