module IV.Pile.SvgAttributes exposing (..)

import Formatting exposing (..)
import Svg
import Svg.Attributes exposing (..)
import VirtualDom

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
     
transformOrigin' : Int -> Int -> Svg.Attribute msg
transformOrigin' x y =
  let 
    argFormatter = print <| int <> s "px " <> int <> s "px"
  in
    VirtualDom.attribute "transform-origin" (argFormatter x y)


