module IV.View.AboutPage exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import IV.Msg exposing (Msg(..))
import IV.Pile.HtmlShorthand exposing (..)
import IV.View.Layout as Layout

view : Html Msg
view =
  row []
    
    [ Layout.headerWith []
    , p []
        [ text """
                This application is intended to be used by teachers and students.
                Any use of it in real medical situations is
                """
        , strong [] [text "at your own risk"]
        , text ". (See the scary legal boilerplate below.)"
        ]
    , p []
        [ text "The app is written in the "
        , a [ href "http://elm-lang.org"]
            [ text "Elm programming language" ]
        , text " and the source is "
        , a [ href "https://github.com/marick/eecrit/tree/master/web/elm/IV" ]
            [ text "freely available" ]
        , text " under the "
        , a [ href "https://en.wikipedia.org/wiki/MIT_License" ]
            [ text "MIT License"]
        , text "."
        ]
    , hr [] []
    , p []
        [ text "Copyright © 2016 Brian Marick" ]
    , p []
        [ text """
                THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
                EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
                OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
                NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
                HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
                WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
                FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
                OTHER DEALINGS IN THE SOFTWARE.
                """
        ]
    , Layout.footerWith (span [] []) Layout.defaultFooterNav
    ]

     
