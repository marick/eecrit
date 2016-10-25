module IV.Apparatus.ChamberView exposing
  ( render
  , startingState
  , startDraining
  , animationClockTick)

import Animation exposing (px)
import Animation.Messenger
import Color
import Svg exposing (..)
import Svg.Attributes exposing (..)

import IV.Apparatus.ViewConstants as C
import IV.Pile.SvgAttributes exposing (..)
import IV.Pile.Animation exposing (easeForHours)
import IV.Types exposing (..)

-- TODO: Use translate so calculations can be ignorant of surroundings, as in
-- transform "translate(50,50)"

render chamberFluid =
  Svg.g
    []
    [fluid chamberFluid, chamber]
      
startingState =
  (toFloat C.puddleHeight) / (toFloat C.chamberHeight)
    |> Level
    |> animatableFluidAttributes
    |> Animation.style

-- Private

startDraining model =
  Animation.interrupt
    [ Animation.toWith
        (easeForHours (Hours 0.1))
        (animatableFluidAttributes (Level 0))
    ]
    model ! []

animationClockTick tick model =
  Animation.Messenger.update tick model
      
chamber = rect
          [ fill "none"
          , stroke "black"
          , x' C.chamberXOffset
          , y' C.bagHeight
          , width' C.chamberWidth
          , height' C.chamberHeight
          ]
          []

animatableFluidAttributes (Level level) =
  let
    height = level * C.chamberHeight
    y = C.chamberHeight - height + C.bagHeight
  in
    [ Animation.y y
    , Animation.height (px height)
    ]
    
fluid chamberFluid =
  rect (Animation.render chamberFluid ++ invariantProperties) []

invariantProperties = 
               [ fill C.fluidColorString
               , x' C.chamberXOffset
               , width' C.chamberWidth
               ]
