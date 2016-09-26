module IV.View exposing (view)

import IV.Msg exposing (Msg)
import IV.Model exposing (Model)
import Html exposing (..)
import Html.Attributes as Attr
import IV.Backdrop exposing (provideBackdropFor)
import IV.Droplet.View as Droplet
import IV.SpeedControl.View as SpeedControl
import IV.Clock.View as Clock

view : Model -> Html Msg
view model =
    div
      [ Attr.style [ ( "margin", "0px auto" ), ( "width", "500px" ), ( "height", "500px" ), ( "cursor", "pointer" ) ]
      ]
      [ provideBackdropFor [(Droplet.render model.droplet), (Clock.render model.clock)]
      , SpeedControl.view model.speedControl
      ]
