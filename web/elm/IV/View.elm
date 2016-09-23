module IV.View exposing (view)

import IV.Msg exposing(Msg(..))
import IV.Model exposing (Model)
import Html exposing (..)
import Html.Attributes as Attr
import IV.Backdrop exposing (provideBackdropFor)
import IV.Droplet.View as Droplet
import Html.Events as Events

view : Model -> Html Msg
view model =
    div
      [
       Attr.style [ ( "margin", "0px auto" ), ( "width", "500px" ), ( "height", "500px" ), ( "cursor", "pointer" ) ]
      ]
      [
        provideBackdropFor [(Droplet.render model.droplet)]
      , input [ Attr.value model.speedControl.string, Events.onInput ChangedTextField] []
      , button [Events.onClick ChangeDripRate ] [ text "Go" ]
      , text (model.droplet.currentSpeed |> toString)
      ]
