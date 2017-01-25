module Pile.Css.Bulma.Util exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Maybe.Extra as Maybe

fullClass : String -> List (Maybe String) -> Attribute msg
fullClass base maybeMoreClasses =
  class <| String.join " " (base :: Maybe.values maybeMoreClasses)
      
control : List (Maybe String) -> List (Html msg) -> Html msg
control maybeMoreClasses content =
  p [fullClass "control" maybeMoreClasses] content

groupedControl : List (Maybe String) -> List (Html msg) -> Html msg
groupedControl maybeMoreClasses content =
  p [fullClass "control is-grouped" maybeMoreClasses] content

controlWithAddons : Html msg -> List (Html msg) -> Html msg
controlWithAddons control addons = 
  div [class "control has-addons"] (control :: addons)

-- I don't actually know why this works    
aShortControlOnItsOwnLine : Html msg -> Html msg
aShortControlOnItsOwnLine control =
  groupedControl [] [control]
