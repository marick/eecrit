module Animals exposing (main)

import Navigation
import Animals.Model as A
import Animals.Update as A
import Animals.View as A
import Animals.Msg as A

main =
    Navigation.programWithFlags A.NoticePageChange
        { init = A.init
        , view = A.view
        , update = A.update
        , subscriptions = always Sub.none
        }


