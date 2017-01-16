module Animals exposing (main)

import Navigation
import Animals.Model as A
import Animals.Update as A
import Animals.View as A
import Animals.Msg as A

main : Program A.Flags A.Model A.Msg
main =
    Navigation.programWithFlags (A.Navigate << A.NoticeChange)
        { init = A.init
        , view = A.view
        , update = A.update
        , subscriptions = always Sub.none
        }


