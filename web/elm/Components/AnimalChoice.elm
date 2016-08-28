module Components.AnimalChoice exposing (view, Model)

import Html exposing (Html, span, strong, em, a, text)
import Html.Attributes exposing (class, href)

type alias Model =
    {name: String, kind: String}

view : Model -> Html a
view model =
    span [class "animal-choice"] [ text (model.name ++ " (" ++ model.kind ++ ")") ]


