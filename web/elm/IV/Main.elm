module IV.Main exposing (..)
import Time exposing (second)
import Html.App
import Html exposing (h1, div, Html, button, input)
import Html.Attributes as Attr
import Html.Events exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Animation exposing (px)
import Color exposing (purple, green, rgb)
import String
import IV.Droplet as Droplet exposing (Droplet)
import IV.StaticImage as StaticImage


type alias Model =
    { droplet : Droplet
    , currentSpeed : Float
    , desiredNextSpeed : String
    }


type Msg
    = Go
    | UpdateSpeed String
    | Animate Animation.Msg


startAnimation model = 
  { model | droplet = Droplet.animate model.droplet model.currentSpeed }

floatSpeed model =
  if String.isEmpty model.desiredNextSpeed then
    model
  else
    case String.toInt model.desiredNextSpeed of
        Ok n ->
          {model | currentSpeed = toFloat n}
        Err _ ->
          model
  
    
updateNextSpeed model nextString =
  if String.isEmpty nextString then
    {model | desiredNextSpeed = nextString}
  else
    case String.toInt nextString of
        Ok _ ->
          {model | desiredNextSpeed = nextString}
        Err _ ->
          model

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Go -> 
          ( model |> floatSpeed |> startAnimation
          , Cmd.none
          )

        UpdateSpeed nextString ->
          ( updateNextSpeed model nextString, Cmd.none)

        Animate time ->
          ( { model
              | droplet = (Animation.update time) model.droplet
            }
          , Cmd.none
          )


view : Model -> Html Msg
view model =
    div
        [Attr.style [ ( "margin", "0px auto" ), ( "width", "500px" ), ( "height", "500px" ), ( "cursor", "pointer" ) ]
        ]
        [ StaticImage.provideBackdropFor [(Droplet.render model.droplet)]
        , input [ Attr.value model.desiredNextSpeed, onInput UpdateSpeed] []
        , button [onClick Go ] [ text "Go" ]
        , text (model.currentSpeed |> toString)
        ]


init : ( Model, Cmd Msg )
init =
    ( { droplet = Droplet.startingState
      , currentSpeed = 800.0
      , desiredNextSpeed = "800"
      }
    , Cmd.none
    )


main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions model =
    Animation.subscription Animate
        [model.droplet]
