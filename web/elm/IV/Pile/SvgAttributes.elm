module IV.Pile.SvgAttributes exposing (..)

import Formatting exposing (..)
import Svg
import Svg.Attributes exposing (..)
import IV.Types exposing (..)
import String

useInt : (String -> a) -> (Int -> a)
useInt stringFn i =
  i |> (print int) |> stringFn


markerWidth_ = useInt markerWidth
markerHeight_ = useInt markerHeight
x_ = useInt x
x1_ = useInt x1
x2_ = useInt x2
y_ = useInt y
y1_ = useInt y1
y2_ = useInt y2
cx_ = useInt cx
cy_ = useInt cy
r_ = useInt r
height_ = useInt height
width_ = useInt width


-- Support for Transforms and the like
         
pointFmt = (float <> s "," <> float)
translateFmt = (s "translate(" <> pointFmt <> s ")") 

translate (x, y) =
  print translateFmt x y

-- Private

toSvgPoint : Point -> String 
toSvgPoint (x, y) =
  print pointFmt x y
               
toSvgPoints : List Point -> String
toSvgPoints points =
  String.join " " <| List.map toSvgPoint points
