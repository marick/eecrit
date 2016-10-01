-- This exists just because I can't seem to make a `main` in IV
-- subdirectory show up in Elixir version.

module IV exposing (main)

import Html.App
import IV.Main as Main
import IV.View as View

main =
    Html.App.program
        { init = Main.init
        , view = View.view
        , update = Main.update
        , subscriptions = Main.subscriptions
        }

