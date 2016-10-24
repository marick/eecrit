module IV.Apparatus.ViewConstants exposing (..)

import Color exposing (Color, rgb)
import Formatting exposing (..)
import IV.Types exposing (Point)
import String

bagWidth = 120
bagHeight = 200

-- The chamber is above the hose. Droplets fall into it.
-- It has a puddle in the bottom.
chamberXOffset = 45
chamberYOffset = bagHeight
chamberWidth = 30
chamberHeight = 90

puddleHeight = 20
puddleYOffset = chamberYOffset + chamberHeight - puddleHeight
                
dropXOffset = 55
dropWidth = 10
dropHeight = 10
streamHeight = puddleYOffset - chamberYOffset

-- Droplets fit exactly into the host               
hoseXOffset = dropXOffset
hoseYOffset = chamberYOffset + chamberHeight
hoseWidth = dropWidth
hoseHeight = 90
                
fluidColor : Color
fluidColor = rgb 211 215 207
fluidColorString = "#d3d7cf"     -- Sigh
variantFluidColor = rgb 193 193 193
whiteColor = rgb 255 255 255           


-- Private

onePoint : Point -> String 
onePoint (x, y) =
  print (float <> s "," <> float) x y
               
nPoints : List Point -> String
nPoints points =
  String.join " " <| List.map onePoint points
