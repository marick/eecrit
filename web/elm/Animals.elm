module Animals exposing (main)

import Animals.Main as Main
import Animals.Navigation as Navigation
import Animals.View as View

main =
    Navigation.programWithFlags Navigation.urlParser 
        { init = Main.init
        , view = View.view
        , update = Main.update
        , urlUpdate = Navigation.urlUpdate
        , subscriptions = Main.subscriptions
        }


