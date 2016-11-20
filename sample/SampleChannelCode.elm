-- This exists just because I can't seem to make a `main` in the
-- subdirectory show up in Elixir version.

module C4u exposing (main)

import C4u.Main as Main
import C4u.Navigation as Navigation
import C4u.View as View

main : Program Main.Flags
main =
    Navigation.programWithFlags Navigation.urlParser 
        { init = Main.init
        , view = View.view
        , update = Main.update
        , urlUpdate = Navigation.urlUpdate
        , subscriptions = Main.subscriptions
        }

