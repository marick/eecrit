module Animals.Pages.HelpPage exposing (..)

import Html exposing (..)
import Pile.Css.Bulma as Css

view : model -> Html msg
view model =
  Css.plainMessage
    [ Css.contentP
        [ text """
                This part of the app works with animals. Animals are added to
                the system ("created") as of a particular date. After that,
                everything that
                happens to an animal, whether it be a name change, a use in
                a classroom, or putting it out on pasture, is tracked.
                That makes it easy to create all kinds of reports for things
                like regulatory compliance.
                """
        ]
    , Css.contentP
        [ text """
                Every animal is different, and those differences are described
                in three ways.
                """
        , ol []
          [ li []
              [text "An animal has a "
              , i [] [text "species"]
              , text ". That never changes."
              ]
          , li []
              [ p []
                 [ text "An animal has "
                 , i [] [text "tags"]
                 , text """. Those are just words. They can be used when working with
                         animals. For example, when working with horses, you might
                         want to look only at mares.
                         """
                 ]
              , p []
                [ text """Tags can change over time. For example, a particular
                        animal might be a calf one year, a heifer calf the next,
                        and then a cow. Which she is might figure into reports
                        or into what procedures she can be used to teach.
                        """
                ]
              ]
          , li []
            [ p []
                [text "An animal can also have "
                , i [] [text "properties"]
                , text """. Whereas tags either apply or not - and that's it -
                        properties both apply and have 
                        """
                , i [] [text "values"]
                , text """. For example, a particular animal may "belong to"
                        (be paid for) by a particular department.
                        So the property "billing authority" would have that
                        department as its value.
                        """
                ]
            , p []
              [ text """Or a
                      particular mare may be marked as "on pasture" as of a
                      particular date. That means she won't be able to be used
                      in classes until she's not on pasture.
                      """
              ]
            , p []
              [ text """In this early version, there's no way to create or
                      change properties. I need to collaborate with real users
                      to see how to best do that.
                      """
              ]
            ]
          ]
        ]
    ]
