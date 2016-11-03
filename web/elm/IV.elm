-- This exists just because I can't seem to make a `main` in IV
-- subdirectory show up in Elixir version.

module IV exposing (main)

import IV.Main as Main
import IV.Navigation as Navigation
import IV.View as View

main =
    Navigation.program Navigation.urlParser 
        { init = Main.init
        , view = View.view
        , update = Main.update
        , urlUpdate = Navigation.urlUpdate
        , subscriptions = Main.subscriptions
        }

