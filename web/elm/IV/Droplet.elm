module IV.Droplet exposing (..)

import Color exposing (purple, green, rgb)
import IV.Palette as Palette
import Animation exposing (px)
import Svg
import Time exposing (second)
import IV.Droplet.Msg exposing (Msg(..))

-- Model

type alias Model = Animation.State

startingState : Animation.State    
startingState = Animation.style starting

starting = [ Animation.points
                       [ ( 55, 200 )
                       , ( 65, 200)
                       , ( 65, 210 )
                       , ( 55, 210 )
                       ]
           , Animation.fill Palette.white
           ]

growing = [ Animation.points
                       [ ( 55, 200 )
                       , ( 65, 200)
                       , ( 65, 210 )
                       , ( 55, 210 )
                       ]
           , Animation.fill Palette.aluminum
           ]

stopping = [ Animation.points
                       [ ( 55, 290 )
                       , ( 65, 290)
                       , ( 65, 300 )
                       , ( 55, 300 )
                       ]
           ]

-- Update

update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangeDripRate v -> 
      let
        -- Will use new mechanism for this shortly
        tempSpeed = Animation.speed {perSecond = v}
        newCommands = [
         Animation.loop
           [
            Animation.wait (0.05 * second)
           , Animation.toWith tempSpeed growing
           , Animation.wait (0.1 * second)
           , Animation.toWith tempSpeed stopping
           , Animation.set starting
           ]
        ]
      in
        Animation.interrupt newCommands model

-- View  

render droplet =
  Svg.polygon (Animation.render droplet) []

