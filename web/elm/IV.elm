-- This exists just because I can't seem to make a `main` in IV
-- subdirectory show up in Elixir version.

module IV exposing (main)

import IV.Main as Main
import Navigation
import IV.View as View
import IV.Msg exposing (Msg(..))

main =
    Navigation.program NoticePageChange
        { init = Main.init
        , view = View.view
        , update = Main.update
        , subscriptions = Main.subscriptions
        }

