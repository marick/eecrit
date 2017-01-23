module Pile.Css.Bulma.Util exposing (..)

import Pile.Css.H exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Pile.HtmlShorthand exposing (..)
import Maybe.Extra as Maybe

fullClass base maybeMoreClasses =
  class <| String.join " " (base :: Maybe.values maybeMoreClasses)
      
control maybeMoreClasses content =
  p [fullClass "control" maybeMoreClasses] content

groupedControl maybeMoreClasses content =
  p [fullClass "control is-grouped" maybeMoreClasses] content

controlWithAddons control addons = 
  div [class "control has-addons"] (control :: addons)

-- I don't actually know why this works    
aShortControlOnItsOwnLine control =
  groupedControl [] [control]
