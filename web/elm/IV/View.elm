module IV.View exposing (view)

import IV.Msg exposing(Msg(..))
import IV.Model exposing (Model)
import Html exposing (..)
import Html.Attributes as Attr
import IV.StaticImage as StaticImage
import IV.Droplet as Droplet
import Html.Events as Events

view : Model -> Html Msg
view model =
    div
      [
       Attr.style [ ( "margin", "0px auto" ), ( "width", "500px" ), ( "height", "500px" ), ( "cursor", "pointer" ) ]
      ]
      [
        StaticImage.provideBackdropFor [(Droplet.render model.droplet)]
      , input [ Attr.value model.desiredNextSpeed, Events.onInput UpdateSpeed] []
      , button [Events.onClick Go ] [ text "Go" ]
      , text (model.currentSpeed |> toString)
      ]




      
