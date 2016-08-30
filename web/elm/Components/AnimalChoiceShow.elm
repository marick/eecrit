module Components.AnimalChoiceShow exposing (..)
import Components.AnimalChoice as AnimalChoice
import Html exposing (..)
import Html.Attributes exposing (href)

type Msg = NoOp

view : AnimalChoice.Model -> Html Msg
view model =
  div []
    [ h3 [] [ text model.name ]
    , text ("... is of kind " ++ model.kind)
    ]
