module Registration exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (class)
import Components.AnimalChoiceList as AnimalChoiceList

-- MODEL 

type alias Model =
    { animalChoiceListModel: AnimalChoiceList.Model
    , currentView : Page
    }

initialModel : Model
initialModel =
    { animalChoiceListModel = AnimalChoiceList.initialModel
    , currentView = RootView
    }

init : (Model, Cmd Msg)
init =
    (initialModel, Cmd.none)

-- UPDATE
        
type Msg
    = AnimalChoiceListMsg AnimalChoiceList.Msg
    | UpdateView Page
    

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        AnimalChoiceListMsg animalChoiceMsg ->
            let (updatedModel, cmd) = AnimalChoiceList.update animalChoiceMsg model.animalChoiceListModel
            in ( { model | animalChoiceListModel = updatedModel }, Cmd.map AnimalChoiceListMsg cmd )
        UpdateView page ->
            ( { model | currentView = page }, Cmd.none)
      

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

-- VIEW

type Page
    = RootView
    | AnimalChoiceListView

pageView : Model -> Html Msg
pageView model =
    case model.currentView of
        RootView ->
            welcomeView
        AnimalChoiceListView ->
            animalChoiceListView model

welcomeView : Html Msg
welcomeView =
    h2 [] [text "Welcome"]

view : Model -> Html Msg
view model =
    div [ class "elm-app" ]
        [ pageView model]

animalChoiceListView : Model -> Html Msg
animalChoiceListView model =
    Html.App.map AnimalChoiceListMsg
        (AnimalChoiceList.view model.animalChoiceListModel)

main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions }

