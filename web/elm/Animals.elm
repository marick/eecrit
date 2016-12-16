module Animals exposing (main)

import Navigation
import Animals.Main as Main
import Animals.View as View
import Animals.Msg exposing (Msg(..))

main =
    Navigation.programWithFlags NoticePageChange
        { init = Main.init
        , view = View.view
        , update = Main.update
        , subscriptions = Main.subscriptions
        }


