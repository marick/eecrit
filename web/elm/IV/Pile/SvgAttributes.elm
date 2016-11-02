module IV.Pile.SvgAttributes exposing (..)

import Formatting exposing (..)
import Svg
import Svg.Attributes exposing (..)
import IV.Types exposing (..)
import String

useInt : (String -> a) -> (Int -> a)
useInt stringFn i =
  i |> (print int) |> stringFn


markerWidth' = useInt markerWidth
markerHeight' = useInt markerHeight
x' = useInt x
x1' = useInt x1
x2' = useInt x2
y' = useInt y
y1' = useInt y1
y2' = useInt y2
cx' = useInt cx
cy' = useInt cy
r' = useInt r
height' = useInt height
width' = useInt width


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
