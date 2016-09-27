module IV.Pile.IntAttributes exposing (..)

import Formatting exposing (..)
import Svg.Attributes exposing (..)

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

